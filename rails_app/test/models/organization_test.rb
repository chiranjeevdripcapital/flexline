# frozen_string_literal: true

require "test_helper"

class OrganizationTest < ActiveSupport::TestCase
  test "outstanding_principal_cents is zero without funded draws" do
    org = Organization.create!(
      name: "No draws",
      importer_external_id: "org-nd-#{SecureRandom.hex(3)}",
      credit_limit_cents: 1_000_000,
      available_cents: 1_000_000,
      portal_status: "active"
    )
    assert_equal 0, org.outstanding_principal_cents
  end

  test "outstanding_principal_cents sums scheduled instalments on funded draws" do
    org = Organization.create!(
      name: "With draws",
      importer_external_id: "org-wd-#{SecureRandom.hex(3)}",
      credit_limit_cents: 2_000_000,
      available_cents: 1_900_000,
      portal_status: "active"
    )
    ba = org.bank_accounts.create!(
      display_name: "Main",
      legal_name_on_account: "With draws",
      account_type: "checking",
      routing_number: "021000021",
      account_number: "1234567890999",
      mask_last4: "0999",
      verification_status: "verified",
      verification_method: "micro_deposit",
      ach_authorization_signed_at: Time.current,
      account_fingerprint: BankAccount.fingerprint_for("021000021", "1234567890999")
    )
    draw = org.draws.create!(bank_account: ba, amount_cents: 100_000, term_months: 6, status: "funded", funded_at: Time.current)
    draw.installments.create!(
      sequence: 1,
      due_on: Date.current + 1.month,
      amount_cents: 20_000,
      principal_cents: 20_000,
      interest_cents: 0,
      status: "scheduled"
    )
    draw.installments.create!(
      sequence: 2,
      due_on: Date.current + 2.months,
      amount_cents: 20_000,
      principal_cents: 20_000,
      interest_cents: 0,
      status: "paid"
    )

    assert_equal 20_000, org.reload.outstanding_principal_cents
  end
end
