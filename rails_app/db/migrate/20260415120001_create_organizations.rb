# frozen_string_literal: true

class CreateOrganizations < ActiveRecord::Migration[8.0]
  def change
    create_table :organizations do |t|
      t.string :name, null: false
      t.integer :credit_limit_cents, null: false, default: 0
      t.integer :available_cents, null: false, default: 0

      t.timestamps
    end
  end
end
