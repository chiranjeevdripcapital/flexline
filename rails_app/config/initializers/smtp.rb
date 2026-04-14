# frozen_string_literal: true

# Optional production SMTP. Set SMTP_ADDRESS (and related ENV vars) after you have provider credentials.
if Rails.env.production? && ENV["SMTP_ADDRESS"].present?
  Rails.application.config.action_mailer.smtp_settings = {
    address: ENV.fetch("SMTP_ADDRESS"),
    port: ENV.fetch("SMTP_PORT", "587").to_i,
    user_name: ENV["SMTP_USER_NAME"].presence,
    password: ENV["SMTP_PASSWORD"].presence,
    authentication: ENV.fetch("SMTP_AUTHENTICATION", "plain").to_sym,
    enable_starttls_auto: ENV.fetch("SMTP_ENABLE_STARTTLS", "true") == "true",
  }.compact
end
