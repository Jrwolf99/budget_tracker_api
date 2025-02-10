class AddAiSuggestedSpendCategory < ActiveRecord::Migration[7.0]
  def change
    add_column :spends, :ai_suggested_spend_category_id, :integer
  end
end
