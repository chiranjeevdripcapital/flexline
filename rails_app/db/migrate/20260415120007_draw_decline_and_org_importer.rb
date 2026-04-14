# frozen_string_literal: true

class DrawDeclineAndOrgImporter < ActiveRecord::Migration[8.0]
  def change
    add_column :draws, :decline_reason, :text

    add_column :organizations, :importer_external_id, :string
    add_column :organizations, :portal_status, :string, null: false, default: "active"

    add_index :organizations, :importer_external_id, unique: true, name: "index_organizations_on_importer_external_id"
  end
end
