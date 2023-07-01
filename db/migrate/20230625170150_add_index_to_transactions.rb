class AddIndexToTransactions < ActiveRecord::Migration[7.0]
  def change
    add_index :transactions, [:description, :amount, :transaction_date], unique: true, name: 'index_transactions_on_desc_amount_date'
  end
end
