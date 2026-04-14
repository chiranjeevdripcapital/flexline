# frozen_string_literal: true

require "test_helper"

class PaymentDateGroupTest < ActiveSupport::TestCase
  test "sums amounts for same due_on across draws" do
    org = Organization.create!(
      name: "Multi draw",
      importer_external_id: "org-md-#{SecureRandom.hex(3)}",
      credit_limit_cents: 2_000_000,
      available_cents: 1_000_000,
      portal_status: "active"
    )
    ba = org.bank_accounts.create!(
      display_name: "Main",
      legal_name_on_account: "Multi draw",
      account_type: "checking",
      routing_number: "021000021",
      account_number: "1234567890888",
      mask_last4: "0888",
      verification_status: "verified",
      verification_method: "micro_deposit",
      ach_authorization_signed_at: Time.current,
      account_fingerprint: BankAccount.fingerprint_for("021000021", "1234567890888")
    )
    d1 = org.draws.create!(bank_account: ba, amount_cents: 10_000_00, term_months: 3, status: "funded")
    d2 = org.draws.create!(bank_account: ba, amount_cents: 5_000_00, term_months: 3, status: "funded")
    date = Date.new(2026, 5, 15)
    d1.installments.create!(sequence: 1, due_on: date, amount_cents: 100_00, principal_cents: 80_00, interest_cents: 20_00, status: "scheduled")
    d1.installments.create!(sequence: 2, due_on: date + 1.month, amount_cents: 100_00, principal_cents: 85_00, interest_cents: 15_00, status: "scheduled")
    d2.installments.create!(sequence: 1, due_on: date, amount_cents: 50_00, principal_cents: 40_00, interest_cents: 10_00, status: "scheduled")

    groups = PaymentDateGroup.for_organization(org)
    may = groups.find { |g| g.due_on == date }
    assert_equal 150_00, may.ach_debit_cents
    assert_equal 120_00, may.principal_cents
    assert_equal 30_00, may.interest_cents
    assert_equal "scheduled", may.status
    assert_equal 2, may.installments.size
  end

  test "status is paid only when all lines for that date are paid" do
    org = Organization.create!(
      name: "Paid mix",
      importer_external_id: "org-pm-#{SecureRandom.hex(3)}",
      credit_limit_cents: 2_000_000,
      available_cents: 1_000_000,
      portal_status: "active"
    )
    ba = org.bank_accounts.create!(
      display_name: "Main",
      legal_name_on_account: "Paid mix",
      account_type: "checking",
      routing_number: "021000021",
      account_number: "1234567890777",
      mask_last4: "0777",
      verification_status: "verified",
      verification_method: "micro_deposit",
      ach_authorization_signed_at: Time.current,
      account_fingerprint: BankAccount.fingerprint_for("021000021", "1234567890777")
    )
    d1 = org.draws.create!(bank_account: ba, amount_cents: 10_000_00, term_months: 3, status: "funded")
    date = Date.new(2026, 6, 1)
    d1.installments.create!(sequence: 1, due_on: date, amount_cents: 100_00, principal_cents: 80_00, interest_cents: 20_00, status: "paid")
    d2 = org.draws.create!(bank_account: ba, amount_cents: 5_000_00, term_months: 3, status: "funded")
    d2.installments.create!(sequence: 1, due_on: date, amount_cents: 50_00, principal_cents: 40_00, interest_cents: 10_00, status: "scheduled")

    group = PaymentDateGroup.for_organization(org).find { |g| g.due_on == date }
    assert_equal "scheduled", group.status

    d2.installments.first.update!(status: "paid")
    group2 = PaymentDateGroup.for_organization(org).find { |g| g.due_on == date }
    assert_equal "paid", group2.status
  end
end
