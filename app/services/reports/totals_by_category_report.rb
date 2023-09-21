# frozen_string_literal: true

module Reports
  class TotalsByCategoryReport
    def initialize(year, month, spend_account, report_type)
      @year = year
      @month = month
      @spend_account = spend_account
      @report_type = report_type
    end

    def generate
      case @report_type
      when 'granular'
        category_totals_of_standard_expenses('spend_categories.name')
      when 'broader'
        category_totals_of_standard_expenses('spend_categories.broad_identifier')
      when 'wants_needs'
        category_totals_of_standard_expenses('spend_categories.is_needed')
      when 'aggregated'
        category_totals_of_standard_expenses('spend_categories.is_standard_expense')
      else
        category_totals_of_standard_expenses('spend_categories.id')
      end
    end

    private

    def category_totals_of_standard_expenses(group_by_thing)
      results = @spend_account.spends
                              .is_standard_expense
                              .in_month_and_year(@month, @year)
                              .joins(:spend_category)
                              .group(group_by_thing)
                              .sum(:amount)

      results.map do |group_by_thing_identifier, value|
        {
          identifier: group_by_thing_identifier,
          label: group_by_thing_identifier,
          goal: goal_for_category(SpendCategory.where(group_by_thing => group_by_thing_identifier).pluck(:id)),
          value: value.abs.to_f.round(2),
          percentage: (value.abs / standard_expense_gross_total.abs * 100).round(2),
          list_of_included_categories: SpendCategory.where(group_by_thing => group_by_thing_identifier).pluck(:name)
        }
      end
    end

    def standard_expense_gross_total
      @spend_account.spends
                    .is_standard_expense
                    .in_month_and_year(@month, @year)
                    .sum(:amount)
    end

    def goal_for_category(category_ids)
      @spend_account.goals
                    .where(month: @month, year: @year, spend_category_id: category_ids)
                    .sum(:target_value)
    end
  end
end
