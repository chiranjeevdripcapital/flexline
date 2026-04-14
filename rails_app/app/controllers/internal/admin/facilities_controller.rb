# frozen_string_literal: true

module Internal
  module Admin
    class FacilitiesController < ActionController::API
      before_action :authenticate_facility_token!

      # POST /internal/admin/facilities/sync
      # JSON: { importer_external_id, name?, credit_limit_cents?, available_cents?, portal_status? }
      def sync
        attrs = facility_params
        if attrs[:importer_external_id].blank?
          render json: { ok: false, error: "importer_external_id_required" }, status: :unprocessable_entity
          return
        end

        @organization = Organization.find_or_initialize_by(importer_external_id: attrs[:importer_external_id])
        @organization.name = attrs[:name] if attrs[:name].present?
        @organization.credit_limit_cents = attrs[:credit_limit_cents].to_i if attrs.key?(:credit_limit_cents)
        @organization.available_cents = attrs[:available_cents].to_i if attrs.key?(:available_cents)
        @organization.portal_status = attrs[:portal_status] if attrs[:portal_status].present?

        if @organization.save
          render json: { ok: true, organization_id: @organization.id }
        else
          render json: { ok: false, errors: @organization.errors.full_messages }, status: :unprocessable_entity
        end
      end

      private

      def facility_params
        params.permit(:importer_external_id, :name, :credit_limit_cents, :available_cents, :portal_status).to_h.symbolize_keys
      end

      def authenticate_facility_token!
        expected = ENV["FLEXLINE_FACILITY_SYNC_TOKEN"].to_s
        if expected.blank?
          render json: { ok: false, error: "sync_token_not_configured" }, status: :unauthorized
          return
        end

        given = request.headers["X-Flexline-Facility-Token"].to_s
        unless ActiveSupport::SecurityUtils.secure_compare(expected, given)
          head :unauthorized
        end
      end
    end
  end
end
