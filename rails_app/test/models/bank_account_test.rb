# frozen_string_literal: true

require "test_helper"

class BankAccountTest < ActiveSupport::TestCase
  setup do
    @org = Organization.create!(
      name: "Bank Acct Co",
      importer_external_id: "org-ba-#{SecureRandom.hex(3)}",
      credit_limit_cents: 1_000_000,
      available_cents: 1_000_000,
      portal_status: "active"
    )
  end

  test "complete_plaid_verification sets ownership_verified and clears ach timestamp" do
    ba = @org.bank_accounts.create!(
      display_name: "Plaid path",
      legal_name_on_account: "Bank Acct Co",
      account_type: "checking",
      routing_number: "021000021",
      account_number: "1234567890333",
      mask_last4: "0333",
      verification_method: "plaid",
      verification_status: "awaiting_plaid",
      account_fingerprint: BankAccount.fingerprint_for("021000021", "1234567890333")
    )
    ba.complete_plaid_verification!(item_id: "item_1", account_id: "acct_1")
    ba.reload
    assert ba.ownership_verified?
    assert_nil ba.ach_authorization_signed_at
    assert_not ba.verified?
  end

  test "complete_ach_authorization moves to verified with timestamp" do
    ba = @org.bank_accounts.create!(
      display_name: "Plaid path",
      legal_name_on_account: "Bank Acct Co",
      account_type: "checking",
      routing_number: "021000021",
      account_number: "1234567890334",
      mask_last4: "0334",
      verification_method: "plaid",
      verification_status: "awaiting_plaid",
      account_fingerprint: BankAccount.fingerprint_for("021000021", "1234567890334")
    )
    ba.complete_plaid_verification!(item_id: "item_1", account_id: "acct_1")
    ba.complete_ach_authorization!
    ba.reload
    assert ba.verified?
    assert ba.ach_authorization_signed_at.present?
  end

  test "verified status requires ach_authorization_signed_at" do
    ba = @org.bank_accounts.new(
      display_name: "Bad",
      legal_name_on_account: "Bank Acct Co",
      account_type: "checking",
      routing_number: "021000021",
      account_number: "1234567890444",
      mask_last4: "0444",
      verification_method: "micro_deposit",
      verification_status: "verified",
      ach_authorization_signed_at: nil,
      account_fingerprint: BankAccount.fingerprint_for("021000021", "1234567890444")
    )
    assert_not ba.valid?(:details)
    assert_includes ba.errors[:ach_authorization_signed_at].join, "must"
  end
end
