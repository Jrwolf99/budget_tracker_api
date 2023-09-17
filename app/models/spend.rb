# frozen_string_literal: true

class Spend < ApplicationRecord
  belongs_to :spend_category, optional: true
  belongs_to :spend_account

  scope :in_month_and_year, lambda { |month, year|
    return where(date_of_spend: Date.new(year.to_i, 1)..Date.new(year.to_i, 12, -1)) if month == 'all'

    date_range = Date.new(year.to_i, month.to_i)..Date.new(year.to_i, month.to_i, -1)
    where(date_of_spend: date_range)
  }

  scope :is_standard_expense, -> { joins(:spend_category).where(spend_categories: { is_standard_expense: true }) }
end
