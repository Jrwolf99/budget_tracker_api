# frozen_string_literal: true

class CreateGoals < ActiveRecord::Migration[7.0]
  def change
    create_table :goals do |t|
      t.decimal :target_value
      t.integer :month
      t.integer :year
      t.references :spend_account, foreign_key: true
      t.references :spend_category, foreign_key: true

      t.timestamps
    end

    add_index :goals, %i[month year spend_account_id spend_category_id], unique: true, name: 'index_goals'
  end
end
