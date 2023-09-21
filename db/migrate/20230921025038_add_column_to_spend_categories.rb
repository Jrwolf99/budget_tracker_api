class AddColumnToSpendCategories < ActiveRecord::Migration[7.0]
  def change
    add_column :spend_categories, :broad_identifier, :string
  end
end
