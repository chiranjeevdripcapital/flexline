# frozen_string_literal: true

require "test_helper"

class AdminEventTest < ActiveSupport::TestCase
  test "record! persists draw-linked event" do
    org = Organization.create!(
      name: "Evt Co",
      importer_external_id: "org-evt-#{SecureRandom.hex(3)}",
      credit_limit_cents: 500_000,
      available_cents: 200_000,
      portal_status: "active"
    )
    ba = org.bank_accounts.create!(
      display_name: "Main",
      legal_name_on_account: "Evt Co",
      account_type: "checking",
      routing_number: "021000021",
      account_number: "1234567890111",
      mask_last4: "0111",
      verification_status: "verified",
      verification_method: "micro_deposit",
      account_fingerprint: BankAccount.fingerprint_for("021000021", "1234567890111")
    )
    draw = org.draws.create!(bank_account: ba, amount_cents: 10_000, term_months: 3, status: "processing")

    AdminEvent.record!(
      action: "draw_declined",
      actor_identifier: "ops.test",
      draw: draw,
      metadata: { "internal_decline_code" => "policy" }
    )

    e = AdminEvent.last
    assert_equal "draw_declined", e.action
    assert_equal "ops.test", e.actor_identifier
    assert_equal org.id, e.organization_id
    assert_equal draw.id, e.draw_id
    assert_equal "policy", e.metadata["internal_decline_code"]
  end
end
