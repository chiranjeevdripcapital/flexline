# frozen_string_literal: true

class ExtendBankAccountsForVerification < ActiveRecord::Migration[8.0]
  def change
    remove_column :bank_accounts, :status, :string

    add_column :bank_accounts, :verification_status, :string, null: false, default: "incomplete"
    add_column :bank_accounts, :verification_method, :string

    add_column :bank_accounts, :legal_name_on_account, :string
    add_column :bank_accounts, :account_type, :string, null: false, default: "checking"

    add_column :bank_accounts, :routing_number, :string
    add_column :bank_accounts, :account_number, :string

    add_column :bank_accounts, :plaid_item_id, :string
    add_column :bank_accounts, :plaid_account_id, :string

    add_column :bank_accounts, :micro_deposit_sent_at, :datetime
    add_column :bank_accounts, :micro_deposit_a_cents, :integer
    add_column :bank_accounts, :micro_deposit_b_cents, :integer
    add_column :bank_accounts, :micro_deposit_attempts, :integer, null: false, default: 0

    add_column :bank_accounts, :failure_reason, :string
    add_column :bank_accounts, :account_fingerprint, :string

    add_column :bank_accounts, :primary_for_disbursement, :boolean, null: false, default: false

    add_index :bank_accounts, %i[organization_id account_fingerprint], unique: true, name: "index_bank_accounts_on_org_and_fingerprint"
  end
end
