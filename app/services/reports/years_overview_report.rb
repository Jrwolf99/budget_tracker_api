# frozen_string_literal: true

module Reports
  class YearsOverviewReport
    def initialize(year, spend_account)
      @year = year
      @spend_account = spend_account
    end

    def generate
      years_expenses.keys.map do |key|
        {
          key:,
          month_name: Date.parse(key.to_s).strftime('%B'),
          month_expenses: years_expenses[key].to_f,
          month_income: years_income[key].to_f,
          month_profit: years_profit[key].to_f,
          month_margin_percentage: "#{years_margin_percentages[key]}%"
        }
      end.sort_by { |month| month[:key] }
    end

    private

    def years_expenses
      @spend_account.spends
                    .in_month_and_year('all', @year)
                    .is_standard_expense
                    .group("DATE_TRUNC('MONTH', date_of_spend)")
                    .sum(:amount)
    end

    def years_income
      @spend_account.spends
                    .in_month_and_year('all', @year)
                    .joins(:spend_category)
                    .where(spend_categories: { identifier: 'income' })
                    .group("DATE_TRUNC('MONTH', date_of_spend)")
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
  end
end
