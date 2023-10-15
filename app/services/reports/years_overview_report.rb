# frozen_string_literal: true

module Reports
  class YearsOverviewReport
    def initialize(year, spend_account)
      @year = year
      @spend_account = spend_account
    end

    def generate
      months = years_expenses.keys.map do |key|
        {
          key:,
          month_name: Date.parse(key.to_s).strftime('%B'),
          month_number: Date.parse(key.to_s).strftime('%m').to_i,
          month_expenses: years_expenses[key].to_f,
          month_income: years_income[key].to_f,
          month_profit: years_profit[key].to_f,
          month_margin_percentage: "#{years_margin_percentages[key]}%"
        }
      end.sort_by { |month| month[:key] }.reverse

      {
        months: months,
        totals: totals
      }

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

    def totals
      {
        total_expenses: years_expenses.values.sum.to_f,
        total_income: years_income.values.sum.to_f,
        total_profit: years_profit.values.sum.to_f,
        total_margin_percentage: "#{years_margin_percentages.values.sum / years_margin_percentages.values.count}%"
      }
    end

  end
end
