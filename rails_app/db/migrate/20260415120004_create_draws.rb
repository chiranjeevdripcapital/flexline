# frozen_string_literal: true

class CreateDraws < ActiveRecord::Migration[8.0]
  def change
    create_table :draws do |t|
      t.references :organization, null: false, foreign_key: true
      t.references :bank_account, null: false, foreign_key: true
      t.integer :amount_cents, null: false
      t.integer :term_months, null: false
      t.string :status, null: false, default: "processing"
      t.datetime :funded_at

      t.timestamps
    end
  end
end
