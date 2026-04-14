# frozen_string_literal: true

class CreateInstallments < ActiveRecord::Migration[8.0]
  def change
    create_table :installments do |t|
      t.references :draw, null: false, foreign_key: true
      t.integer :sequence, null: false
      t.date :due_on, null: false
      t.integer :amount_cents, null: false
      t.integer :principal_cents, null: false
      t.integer :interest_cents, null: false, default: 0
      t.string :status, null: false, default: "scheduled"

      t.timestamps
    end

    add_index :installments, %i[draw_id sequence], unique: true
  end
end
