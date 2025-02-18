class AddAiRulesToSpendAccount < ActiveRecord::Migration[7.0]
  def change
    add_column :spend_accounts, :ai_rules, :text
  end
end
