# frozen_string_literal: true

require "active_support/core_ext/integer/time"

Rails.application.configure do
  config.enable_reloading = false
  config.eager_load = true
  config.consider_all_requests_local = false
  config.public_file_server.enabled = ENV["RAILS_SERVE_STATIC_FILES"].present?
  config.active_support.report_deprecations = false
  config.log_tags = [ :request_id ]
  config.logger = ActiveSupport::Logger.new($stdout)
  config.logger.formatter = config.log_formatter
  config.log_level = ENV.fetch("RAILS_LOG_LEVEL", "info")
  config.action_mailer.perform_caching = false
  config.i18n.fallbacks = true
  config.active_record.dump_schema_after_migration = false

  config.action_mailer.default_url_options = { host: ENV.fetch("APP_HOST", "example.com"), protocol: "https" }
  config.action_mailer.perform_deliveries = true
  config.action_mailer.raise_delivery_errors = ENV["MAILER_RAISE_DELIVERY_ERRORS"] == "true"
  config.action_mailer.delivery_method =
    if ENV["SMTP_ADDRESS"].present?
      :smtp
    elsif ENV["MAILER_DELIVERY_METHOD"].present?
      ENV["MAILER_DELIVERY_METHOD"].to_sym
    else
      :logger
    end
end
