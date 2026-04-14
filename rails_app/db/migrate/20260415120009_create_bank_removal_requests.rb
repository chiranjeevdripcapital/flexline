# frozen_string_literal: true

class CreateBankRemovalRequests < ActiveRecord::Migration[8.0]
  def change
    create_table :bank_removal_requests do |t|
      t.references :organization, null: false, foreign_key: true
      t.references :bank_account, null: false, foreign_key: true
      t.text :borrower_reason, null: false
      t.string :status, null: false, default: "pending_review"
      t.text :operator_notes
      t.string :reviewer_identifier
      t.datetime :reviewed_at
      t.timestamps
    end

    add_index :bank_removal_requests, %i[bank_account_id status]
    add_index :bank_removal_requests, :status
  end
end
