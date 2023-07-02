class ChangeTransactionCategoryStringToReference < ActiveRecord::Migration[7.0]
  def change
    remove_column :transactions, :category, :string
    add_reference :transactions, :category, foreign_key: true
  end
end
