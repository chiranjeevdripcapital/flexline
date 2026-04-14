# frozen_string_literal: true

class AddAchAuthorizationToBankAccounts < ActiveRecord::Migration[8.0]
  def up
    add_column :bank_accounts, :ach_authorization_signed_at, :datetime
    execute <<-SQL.squish
      UPDATE bank_accounts
      SET ach_authorization_signed_at = CURRENT_TIMESTAMP
      WHERE verification_status = 'verified';
    SQL
  end

  def down
    remove_column :bank_accounts, :ach_authorization_signed_at
  end
end
