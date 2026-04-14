# frozen_string_literal: true

module Admin
  class BankRemovalRequestsController < Admin::ApplicationController
    before_action :set_request, only: %i[show approve reject]

    def index
      scope = BankRemovalRequest.includes(:organization, :bank_account).recent_first
      st = params[:status].to_s.strip
      scope = scope.where(status: st) if st.present? && BankRemovalRequest::STATUSES.include?(st)
      @requests = scope.limit(150)
    end

    def show
    end

    def approve
      if @request.approve!(reviewer: admin_actor_identifier, operator_notes: params[:operator_notes].to_s.strip.presence)
        AdminEvent.record!(
          action: "bank_removal_approved",
          actor_identifier: admin_actor_identifier,
          organization: @request.organization,
          bank_account: @request.bank_account,
          metadata: {
            "bank_removal_request_id" => @request.id,
            "borrower_reason_preview" => @request.borrower_reason.truncate(200)
          }
        )
        redirect_to admin_bank_removal_request_path(@request), notice: "Removal approved. Account marked removed in portal."
      else
        redirect_to admin_bank_removal_request_path(@request), alert: @request.errors.full_messages.presence || "Could not approve."
      end
    end

    def reject
      if @request.reject!(reviewer: admin_actor_identifier, operator_notes: params[:operator_notes].to_s.strip.presence)
        AdminEvent.record!(
          action: "bank_removal_rejected",
          actor_identifier: admin_actor_identifier,
          organization: @request.organization,
          bank_account: @request.bank_account,
          metadata: { "bank_removal_request_id" => @request.id }
        )
        redirect_to admin_bank_removal_request_path(@request), notice: "Request rejected. Bank account stays verified."
      else
        redirect_to admin_bank_removal_request_path(@request), alert: @request.errors.full_messages.presence || "Could not reject."
      end
    end

    private

    def set_request
      @request = BankRemovalRequest.includes(:organization, :bank_account).find(params[:id])
    end
  end
end
