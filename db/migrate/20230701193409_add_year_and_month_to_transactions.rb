class AddYearAndMonthToTransactions < ActiveRecord::Migration[7.0]
  def change
    add_column :transactions, :year, :integer
    add_column :transactions, :month, :integer

    Transaction.reset_column_information
    Transaction.find_each do |transaction|
      transaction.update(year: transaction.transaction_date.year, month: transaction.transaction_date.month)
    end
  end
end
