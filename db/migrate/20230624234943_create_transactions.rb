class CreateTransactions < ActiveRecord::Migration[7.0]
  def change
    create_table :transactions do |t|
      t.string :description
      t.decimal :amount
      t.string :category

      t.timestamps
    end
  end
end
