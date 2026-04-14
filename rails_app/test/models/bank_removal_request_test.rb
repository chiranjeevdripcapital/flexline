# frozen_string_literal: true

require "test_helper"

class BankRemovalRequestTest < ActiveSupport::TestCase
  setup do
    @org = Organization.create!(
      name: "Removal Co",
      importer_external_id: "org-br-#{SecureRandom.hex(3)}",
      credit_limit_cents: 1_000_000,
      available_cents: 500_000,
      portal_status: "active"
    )
    @ba1 = create_verified_account!(@org, "1111111111111", "1111")
    @ba2 = create_verified_account!(@org, "2222222222222", "2222")
  end

  test "cannot create request without another verified account" do
    @ba2.update!(verification_status: "removed")
    req = @org.bank_removal_requests.build(bank_account: @ba1, borrower_reason: "x" * 25)
    assert_not req.valid?
    assert_includes req.errors[:base].join, "other verified"
  end

  test "approve marks bank removed and keeps another verified" do
    req = @org.bank_removal_requests.create!(bank_account: @ba1, borrower_reason: "Closing this operating account at JPM.")
    assert req.pending_review?
    assert req.approve!(reviewer: "admin", operator_notes: "Risk OK")
    @ba1.reload
    assert @ba1.removed?
    assert @ba2.reload.verified?
    assert_equal "approved", req.reload.status
  end

  test "reject leaves bank verified" do
    req = @org.bank_removal_requests.create!(bank_account: @ba1, borrower_reason: "x" * 25)
    assert req.reject!(reviewer: "admin", operator_notes: "Need more docs")
    assert_equal "rejected", req.reload.status
    assert @ba1.reload.verified?
  end

  def create_verified_account!(org, account_number, last4)
    org.bank_accounts.create!(
      display_name: "Acct #{last4}",
      legal_name_on_account: org.name,
      account_type: "checking",
      routing_number: "021000021",
      account_number: account_number,
      mask_last4: last4,
      verification_status: "verified",
      verification_method: "micro_deposit",
      ach_authorization_signed_at: Time.current,
      account_fingerprint: BankAccount.fingerprint_for("021000021", account_number),
      primary_for_disbursement: false
    )
  end
end
