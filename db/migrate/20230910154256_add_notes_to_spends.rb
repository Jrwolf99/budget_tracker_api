# frozen_string_literal: true

class AddNotesToSpends < ActiveRecord::Migration[7.0]
  def change
    add_column :spends, :notes, :string
  end
end
