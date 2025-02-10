# frozen_string_literal: true

class Spend < ApplicationRecord
  belongs_to :spend_category, optional: true
  belongs_to :ai_suggested_spend_category, class_name: 'SpendCategory', optional: true
  belongs_to :spend_account

  scope :in_month_and_year, lambda { |month, year|
    return where(date_of_spend: Date.new(year.to_i, 1)..Date.new(year.to_i, 12, -1)) if month == 'all'

    date_range = Date.new(year.to_i, month.to_i)..Date.new(year.to_i, month.to_i, -1)
    where(date_of_spend: date_range)
  }

  scope :is_standard_expense, -> { joins(:spend_category).where(spend_categories: { is_standard_expense: true }) }

  scope :is_income, -> { where(spend_category_id: SpendCategory.find_by_identifier('income').id) }

  scope :with_category_identifier, lambda { |identifier|
                                   if identifier == 'all'
                                     all
                                   elsif identifier == 'uncategorized'
                                     where(spend_category_id: nil)
                                   else
                                     where(spend_category_id: SpendCategory.find_by_identifier(identifier)&.id)
                                   end
                                 }

  scope :no_ai_suggested_spend_category, -> { where(ai_suggested_spend_category_id: nil) }
end
