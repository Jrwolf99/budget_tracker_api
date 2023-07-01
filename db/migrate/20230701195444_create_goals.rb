class CreateGoals < ActiveRecord::Migration[7.0]
 
  def change
    create_table :goals do |t|
      t.integer :month, null: false
      t.integer :year, null: false
      t.references :category, null: false, foreign_key: true
      t.decimal :goal_amount, precision: 10, scale: 2

      t.timestamps
    end

    add_index :goals, [:category_id, :month, :year], unique: true
  end


end
