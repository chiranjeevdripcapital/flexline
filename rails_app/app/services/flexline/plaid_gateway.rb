# frozen_string_literal: true

module Flexline
  # Server-side Plaid Link + token exchange. Requires PLAID_CLIENT_ID, PLAID_SECRET, and PLAID_ENV
  # (sandbox | development | production). Optional: remove linked Item after verification so we do not
  # retain long-lived access tokens in the pilot database.
  class PlaidGateway
    class ConfigurationError < StandardError; end

    def self.configured?
      ENV["PLAID_CLIENT_ID"].present? && ENV["PLAID_SECRET"].present?
    end

    def self.create_link_token(bank_account:)
      raise ConfigurationError, "Plaid is not configured" unless configured?

      client = plaid_client
      webhook = ENV["PLAID_WEBHOOK_URL"].presence
      attrs = {
        user: { client_user_id: "org-#{bank_account.organization_id}-bank-#{bank_account.id}" },
        client_name: "Flexline",
        products: [ "auth" ],
        country_codes: [ "US" ],
        language: "en",
      }
      attrs[:webhook] = webhook if webhook.present? && webhook.match?(/\Ahttps?:\/\//)
      request = Plaid::LinkTokenCreateRequest.new(attrs)

      response = client.link_token_create(request)
      response.link_token
    end

    def self.exchange_and_finalize_bank_account!(bank_account:, public_token:, plaid_account_id:)
      raise ConfigurationError, "Plaid is not configured" unless configured?

      client = plaid_client
      ex = Plaid::ItemPublicTokenExchangeRequest.new
      ex.public_token = public_token
      response = client.item_public_token_exchange(ex)
      access_token = response.access_token
      item_id = response.item_id

      bank_account.complete_plaid_verification!(item_id: item_id, account_id: plaid_account_id)

      remove_item_if_configured(client, access_token)
      true
    end

    def self.remove_item_if_configured(client, access_token)
      return if ENV["PLAID_RETAIN_ACCESS_TOKEN"] == "true"

      req = Plaid::ItemRemoveRequest.new
      req.access_token = access_token
      client.item_remove(req)
    rescue Plaid::ApiError => e
      Rails.logger.warn("[PlaidGateway] item_remove skipped: #{e.message}")
    end

    def self.plaid_client
      configuration = Plaid::Configuration.new
      env_key = ENV.fetch("PLAID_ENV", "sandbox").downcase
      configuration.server_index =
        Plaid::Configuration::Environment[env_key] || Plaid::Configuration::Environment["sandbox"]
      configuration.api_key["PLAID-CLIENT-ID"] = ENV.fetch("PLAID_CLIENT_ID")
      configuration.api_key["PLAID-SECRET"] = ENV.fetch("PLAID_SECRET")

      api_client = Plaid::ApiClient.new(configuration)
      Plaid::PlaidApi.new(api_client)
    end
    private_class_method :plaid_client, :remove_item_if_configured
  end
end
