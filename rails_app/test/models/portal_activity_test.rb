# frozen_string_literal: true

require "test_helper"

class PortalActivityTest < ActiveSupport::TestCase
  test "includes recent draws and verified bank accounts" do
    org = Organization.create!(
      name: "Activity Co",
      importer_external_id: "act-#{SecureRandom.hex(3)}",
      credit_limit_cents: 1_000_000,
      available_cents: 1_000_000,
      portal_status: "active"
    )
    ba = org.bank_accounts.create!(
      display_name: "Main",
      legal_name_on_account: "Activity Co",
      account_type: "checking",
      routing_number: "021000021",
      account_number: "1234567890888",
      mask_last4: "0888",
      verification_status: "verified",
      verification_method: "micro_deposit",
      account_fingerprint: BankAccount.fingerprint_for("021000021", "1234567890888")
    )
    org.draws.create!(bank_account: ba, amount_cents: 10_000, term_months: 6, status: "processing")

    items = PortalActivity.for_organization(org)
    assert items.any? { |i| i.headline.start_with?("Draw FL-") }
    assert items.any? { |i| i.headline == "Bank account verified" }
  end
end
