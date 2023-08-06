class AddIdentifierToCategories < ActiveRecord::Migration[7.0]
  def change
    add_column :categories, :identifier, :string
  end
end
