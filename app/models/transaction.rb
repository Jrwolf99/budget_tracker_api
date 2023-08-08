class Transaction < ApplicationRecord
  
  belongs_to :category, optional: true

  scope :in_month_and_year, ->(month, year) {(month == 'all' || month == 0) ? where(year:) : where(month:, year:) }
  scope :where_category, ->(category_identifier) {
                            where(category_id: Category.find_by(identifier: category_identifier).id)
                            }
  scope :uncategorized, -> { where(category_id: nil) }


  def self.get_list_of_categories_with_monthly_expenses(month, year)
    total_monthly_expense_amount = in_month_and_year(month, year)
                                    .join(:categories)
                                    .excluding_categories
                                   .sum(:amount).abs.to_f

    totals_by_category = in_month_and_year(month, year)
                                    .join(:categories)
                                    .excluding_categories
                                    .group(:category_id)
                                    .sum(:amount)

    totals_by_category.map do |category_id, value|
      month = 0 if month == 'all'
      goal = Goal.find_by(month:, year:, category_id:)&.goal_amount.to_f
      absolute_value = value.abs.to_f
      percentage = (absolute_value / total_monthly_expense_amount * 100).round(0)
      {
        category: Category.find(category_id).category_name,
        value: absolute_value,
        goal:,
        percentage: percentage || 0
      }
    end.sort_by { |category| category[:percentage] }.reverse
  end



  def self.get_all_expenses_by_category_by_month(month, year, category_identifier)
    in_month_and_year(month, year)
      .where_category(category_identifier)
      .sum(:amount).abs.to_f
  end
  

  def self.get_all_expenses_by_month(month, year)
    in_month_and_year(month, year)
    .sum(:amount).abs.to_f
  end

end