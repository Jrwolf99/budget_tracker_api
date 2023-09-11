class CreateSpends < ActiveRecord::Migration[7.0]
  def change
    create_table :spends do |t|
      t.references :spend_account, null: false, foreign_key: true
      t.references :spend_category, foreign_key: true

      t.string :description, null: false
      t.decimal :amount, null: false
      t.date :date_of_spend, null: false
      t.timestamps
    end
  end
end
