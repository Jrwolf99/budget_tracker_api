class Transaction < ApplicationRecord
  
  belongs_to :category, optional: true

  scope :in_month_and_year, ->(month, year) {(month == 'all' || month == 0) ? where(year:) : where(month:, year:) }
  scope :where_category, ->(category_identifier) {
                            where(category_id: Category.find_by(identifier: category_identifier).id)
                            }
  scope :uncategorized, -> { where(category_id: nil) }


  def self.get_list_of_categories_with_monthly_expenses(month, year)
    
    total_monthly_expense_amount = in_month_and_year(month, year)
                                  .joins(:category)
                                  .merge(Category.excluding_categories)
                                  .sum(:amount).abs.to_f

    totals_by_category = in_month_and_year(month, year)
                        .joins(:category)
                        .merge(Category.excluding_categories)
                        .group('categories.id')
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


  def self.get_overview_report(year)
    result = []
    (0..12).each do |month|
      month = 0 if month == 'all'
      total_expenses = in_month_and_year(month, year)
                       .joins(:category)
                       .merge(Category.excluding_categories)
                       .sum(:amount).abs.to_f

      total_income = in_month_and_year(month, year)
                     .joins(:category)
                     .merge(Category.where(identifier: 'income'))
                     .sum(:amount).abs.to_f

      total_profit = (total_income - total_expenses).round(2)

      profit_margin = (total_profit / total_income * 100).round(2)

      result << {
        month:,
        total_expenses:,
        total_income:,
        total_profit:,
        profit_margin:,
      }
    end
    result
  end

end

