# frozen_string_literal: true

class CreateSpendAccounts < ActiveRecord::Migration[7.0]
  def change
    create_table :spend_accounts do |t|
      t.references :user, null: false, foreign_key: true

      t.timestamps
    end
  end
end
