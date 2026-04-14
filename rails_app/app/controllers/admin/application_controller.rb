# frozen_string_literal: true

module Admin
  class ApplicationController < ActionController::Base
    layout "admin"

    before_action :require_admin_http_basic

    private

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
