class CreateGoals < ActiveRecord::Migration[7.0]
  def change
    create_table :goals do |t|
      t.string :name
      t.decimal :target_value
      t.integer :month
      t.integer :year
      t.references :spend_account, foreign_key: true
      
      t.timestamps
    end

    add_index :goals, [:month, :year, :spend_account_id], unique: true
  end
end
