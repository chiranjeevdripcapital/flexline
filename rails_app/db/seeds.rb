# frozen_string_literal: true

org = Organization.find_or_initialize_by(name: "Demo Company Ltd.")
org.assign_attributes(credit_limit_cents: 15_000_000, available_cents: 8_750_000)
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
