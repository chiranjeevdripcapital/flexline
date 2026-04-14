# frozen_string_literal: true

module Admin
  class ApplicationController < ActionController::Base
    layout "admin"

    before_action :require_admin_http_basic
    before_action :set_admin_actor

    helper_method :admin_actor_identifier

    private

    def set_admin_actor
      @admin_actor_identifier = http_basic_username.presence || "unknown"
    end

    def admin_actor_identifier
      @admin_actor_identifier
    end

    def http_basic_username
      auth = request.authorization
      return nil unless auth&.start_with?("Basic ")

      decoded = Base64.decode64(auth.delete_prefix("Basic ").strip)
      decoded.split(":", 2).first
    rescue ArgumentError, StandardError
      nil
    end

    def require_admin_http_basic
      authenticate_or_request_with_http_basic("Flexline Admin") do |username, password|
        next false if expected_admin_password.blank?

        ActiveSupport::SecurityUtils.secure_compare(username, expected_admin_username) &&
          ActiveSupport::SecurityUtils.secure_compare(password, expected_admin_password)
      end
    end

    def expected_admin_username
      ENV.fetch("FLEXLINE_ADMIN_USERNAME", "admin")
    end

    def expected_admin_password
      ENV["FLEXLINE_ADMIN_PASSWORD"].presence ||
        ((Rails.env.development? || Rails.env.test?) ? "development" : "")
    end
  end
end
