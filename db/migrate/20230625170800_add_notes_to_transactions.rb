class AddNotesToTransactions < ActiveRecord::Migration[7.0]
  def change
    add_column :transactions, :notes, :string, limit: 50
  end
end
