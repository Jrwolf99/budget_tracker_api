# frozen_string_literal: true

class Reports::YearsOverviewReport
  def initialize(spend_account, year, spend_category_identifier)
    @year = year
    @spend_account = spend_account
    @spend_category_identifier = spend_category_identifier
  end

  def generate
    months = years_expenses.keys.map do |month_number|
      {
        key: month_number,
        month_name:  Date::MONTHNAMES[month_number],
        month_number:,
        month_expenses: years_expenses[month_number].to_f,
        month_income: years_income[month_number].to_f,
        month_profit: years_profit[month_number].to_f,
        month_margin_percentage: "#{years_margin_percentages[month_number]}%",
        month_expense_goals: years_expense_goals[month_number.to_i].to_f
      }
    end.sort_by { |month| month[:month_number] }
    {
      months:,
      totals:
    }
  end

  private

  def years_expenses
    expenses = @spend_account.spends
                             .in_month_and_year('all', @year)
                             .is_standard_expense
                             .with_category_identifier(@spend_category_identifier)
                             .group("EXTRACT(MONTH FROM date_of_spend)")
                             .sum(:amount)

    expenses
  end

  def years_income
    @spend_account.spends
                  .in_month_and_year('all', @year)
                  .joins(:spend_category)
                  .where(spend_categories: { identifier: 'income' })
                  .group("EXTRACT(MONTH FROM date_of_spend)")
                  .sum(:amount)
  end

  def years_profit
    # income - expenses, but because expenses is negative, this is a plus.
    years_income.merge(years_expenses) { |_key, income, expenses| income + expenses }
  end

  def years_margin_percentages
    # profit / income
    years_profit.merge(years_income) { |_key, profit, income| (profit * 100 / income).round(0) }
  end

  def years_expense_goals
    goals = @spend_account.goals
                          .where(year: @year)
                          .with_category_identifier(@spend_category_identifier)
                          .group("month")
                          .sum(:target_value)
    puts goals
    goals
  end

  def totals
    {
      total_expenses: years_expenses.values.sum.to_f,
      total_expense_goals: years_expense_goals.values.sum.to_f,
      total_income: years_income.values.sum.to_f,
      total_profit: years_profit.values.sum.to_f,
      total_margin_percentage: years_margin_percentages.values.count.zero? ? '0%' : "#{years_margin_percentages.values.sum / years_margin_percentages.values.count}%"
    }
  end
end
