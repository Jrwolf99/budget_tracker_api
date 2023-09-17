# frozen_string_literal: true

class CreateSpendCategories < ActiveRecord::Migration[7.0]
  def change
    create_table :spend_categories do |t|
      t.string :name, null: false
      t.string :identifier, null: false
      t.boolean :is_standard_expense, null: false, default: false
      t.boolean :is_needed
      t.timestamps
    end
  end
end
