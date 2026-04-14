# frozen_string_literal: true

class Phase1AdminEventsAndDrawOps < ActiveRecord::Migration[8.0]
  def change
    add_column :draws, :operator_notes, :text
    add_column :draws, :internal_decline_code, :string

    create_table :admin_events do |t|
      t.string :action, null: false
      t.string :actor_identifier, null: false
      t.references :organization, null: true, foreign_key: true
      t.references :draw, null: true, foreign_key: true
      t.references :bank_account, null: true, foreign_key: true
      t.json :metadata, default: {}
      t.timestamps
    end

    add_index :admin_events, :action
    add_index :admin_events, :created_at
  end
end
