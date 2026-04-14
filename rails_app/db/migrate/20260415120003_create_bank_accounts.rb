# frozen_string_literal: true

class CreateBankAccounts < ActiveRecord::Migration[8.0]
  def change
    create_table :bank_accounts do |t|
      t.references :organization, null: false, foreign_key: true
      t.string :display_name, null: false
      t.string :mask_last4, null: false
      t.string :status, null: false, default: "pending_verification"

      t.timestamps
    end
  end
end
