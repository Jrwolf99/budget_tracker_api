# frozen_string_literal: true

module Reports
  class TotalsByCategoryReport
    def initialize(year, month, spend_account)
      @year = year
      @month = month
      @spend_account = spend_account
    end

    def generate
      category_totals_of_standard_expenses
    end

    private

    def category_totals_of_standard_expenses
      results = @spend_account.spends
                              .is_standard_expense
                              .in_month_and_year(@month, @year)
                              .joins(:spend_category)
                              .group(:spend_category_id, 'spend_categories.name')
                              .sum(:amount)

      results.map do |category_id_and_name, value|
        {
          category_id: category_id_and_name[0],
          category_name: category_id_and_name[1],
          goal: 1000,
          value: value.abs.to_f.round(2),
          percentage: (value.abs / standard_expense_gross_total.abs * 100).round(2)
        }
      end
    end

    def standard_expense_gross_total
      @spend_account.spends
                    .is_standard_expense
                    .in_month_and_year(@month, @year)
                    .sum(:amount)
    end
  end
end
