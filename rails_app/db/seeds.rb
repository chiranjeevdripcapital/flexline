# frozen_string_literal: true

org = Organization.find_or_initialize_by(importer_external_id: "demo-importer-001")
org.assign_attributes(
  name: "Demo Company Ltd.",
  credit_limit_cents: 15_000_000,
  available_cents: 8_750_000,
  portal_status: "active"
)
org.save!

user = User.find_or_initialize_by(email: "pilot@example.com")
user.organization = org
user.password = "password123"
user.password_confirmation = "password123"
user.save!

fp1 = BankAccount.fingerprint_for("021000021", "1100000004421")
verified = BankAccount.find_or_initialize_by(organization: org, account_fingerprint: fp1)
verified.assign_attributes(
  display_name: "Operating · JPM",
  legal_name_on_account: "Demo Company Ltd.",
  account_type: "checking",
  routing_number: "021000021",
  account_number: "1100000004421",
  mask_last4: "4421",
  verification_status: "verified",
  verification_method: "plaid",
  primary_for_disbursement: true,
  plaid_item_id: "seed_item",
  plaid_account_id: "seed_account"
)
verified.save!(context: :details)

fp2 = BankAccount.fingerprint_for("011401533", "2200000008890")
pending_micro = BankAccount.find_or_initialize_by(organization: org, account_fingerprint: fp2)
pending_micro.assign_attributes(
  display_name: "Payroll · BoA",
  legal_name_on_account: "Demo Company Ltd.",
  account_type: "checking",
  routing_number: "011401533",
  account_number: "2200000008890",
  mask_last4: "8890",
  verification_status: "micro_deposit_sent",
  verification_method: "micro_deposit",
  primary_for_disbursement: false,
  micro_deposit_sent_at: 2.days.ago,
  micro_deposit_attempts: 0
)
pending_micro.save!(context: :details)
pending_micro.update_columns(
  micro_deposit_a_cents: 33,
  micro_deposit_b_cents: 41,
  micro_deposit_sent_at: 2.days.ago
)

# Second borrower org + user (switch logins to compare two facilities in portal + admin).
org2 = Organization.find_or_initialize_by(importer_external_id: "demo-importer-002")
org2.assign_attributes(
  name: "Second Pilot LLC",
  credit_limit_cents: 12_000_000,
  available_cents: 10_000_000,
  portal_status: "active"
)
org2.save!

user2 = User.find_or_initialize_by(email: "pilot2@example.com")
user2.organization = org2
user2.password = "password123"
user2.password_confirmation = "password123"
user2.save!

fp3 = BankAccount.fingerprint_for("021000021", "9900000003322")
ba2 = BankAccount.find_or_initialize_by(organization: org2, account_fingerprint: fp3)
ba2.assign_attributes(
  display_name: "Operating · Chase",
  legal_name_on_account: "Second Pilot LLC",
  account_type: "checking",
  routing_number: "021000021",
  account_number: "9900000003322",
  mask_last4: "3322",
  verification_status: "verified",
  verification_method: "plaid",
  primary_for_disbursement: true,
  plaid_item_id: "seed_item_2",
  plaid_account_id: "seed_account_2"
)
ba2.save!(context: :details)

# One processing draw per demo org so `/admin` and `/admin/draws` show a queue without manual setup.
unless org.draws.where(status: "processing").exists?
  org.draws.create!(
    bank_account: verified,
    amount_cents: 250_000,
    term_months: 6,
    status: "processing"
  )
end

unless org2.draws.where(status: "processing").exists?
  org2.draws.create!(
    bank_account: ba2,
    amount_cents: 180_000,
    term_months: 3,
    status: "processing"
  )
end
