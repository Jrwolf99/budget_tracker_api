class AddColumnsToSpends < ActiveRecord::Migration[7.0]
  def change
    add_column :spends, :locked_from_importer_at, :datetime
    add_column :spends, :import_combo_identifier, :string
    add_column :spends, :last_four, :string
  end
end
