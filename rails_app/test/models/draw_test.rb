# frozen_string_literal: true

require "test_helper"

class DrawTest < ActiveSupport::TestCase
  setup do
    @org = Organization.create!(
      name: "Draw Test Co",
      importer_external_id: "draw-test-#{SecureRandom.hex(4)}",
      credit_limit_cents: 500_000,
      available_cents: 200_000,
      portal_status: "active"
    )
    @bank = @org.bank_accounts.create!(
      display_name: "Ops",
      legal_name_on_account: "Draw Test Co",
      account_type: "checking",
      routing_number: "021000021",
      account_number: "1234567890123",
      mask_last4: "0123",
      verification_status: "verified",
      verification_method: "micro_deposit",
      account_fingerprint: BankAccount.fingerprint_for("021000021", "1234567890123")
    )
  end

  test "approve_and_fund moves draw to funded and debits availability" do
    draw = @org.draws.create!(bank_account: @bank, amount_cents: 50_000, term_months: 6, status: "processing")
    assert draw.approve_and_fund!
    draw.reload
    assert_equal "funded", draw.status
    assert_equal 450_000, @org.reload.available_cents
    assert_equal 450_000, @org.available_for_draws_cents
    assert_equal 6, draw.installments.count
  end

  test "decline sets status and reason" do
    draw = @org.draws.create!(bank_account: @bank, amount_cents: 10_000, term_months: 3, status: "processing")
    assert draw.decline!(reason: "Policy check")
    draw.reload
    assert_equal "declined", draw.status
    assert_includes draw.decline_reason, "Policy"
  end

  test "create draw rejects amount above available" do
    draw = @org.draws.new(bank_account: @bank, amount_cents: 999_999_999, term_months: 6, status: "processing")
    assert_not draw.save
    assert_includes draw.errors[:amount_cents].join, "exceeds"
  end
end
