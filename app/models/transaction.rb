class Transaction < ApplicationRecord
  belongs_to :category, optional: true

  scope :in_month_and_year, ->(month, year) { where(month:, year:) }
  scope :in_year, ->(year) { where(year:) }
  scope :excluding_categories, ->(category_ids) { where.not(category_id: category_ids) }
  scope :with_category, ->(category_id) { where(category_id:) }

  def self.get_totals_by_category(month, year)
    if month == 'all'
      total_monthly_expense_amount = in_year(year)
                                     .excluding_categories([5, 8, 11, 12])
                                     .sum(:amount).abs.to_f
      totals_by_category = in_year(year)
                           .excluding_categories([5, 8, 11, 12])
                           .group(:category_id)
                           .sum(:amount)
    else
      total_monthly_expense_amount = in_month_and_year(month, year)
                                     .excluding_categories([5, 8, 11, 12])
                                     .sum(:amount).abs.to_f

      totals_by_category = in_month_and_year(month, year)
                           .excluding_categories([5, 8, 11, 12])
                           .group(:category_id)
                           .sum(:amount)
    end

    totals_by_category.map do |category_id, value|
      goal = Goal.find_by(month:, year:, category_id:)&.goal_amount.to_f
      absolute_value = value.abs.to_f
      percentage = (absolute_value / total_monthly_expense_amount * 100).round(0)

      {
        category: Category.find(category_id).category_name,
        value: absolute_value,
        goal:,
        percentage: percentage || 0
      }
    end
  end
end
