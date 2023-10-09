# frozen_string_literal: true

module Reports
  class TotalsByCategoryReport
    def initialize(spend_account:, report_params:)
      @spend_account = spend_account
      @year = report_params[:year]
      @month = report_params[:month]
      @report_type = report_params[:report_type]
      @only_needs_or_only_wants = report_params[:only_needs_or_only_wants]
    end

    def generate
      case @report_type
      when 'granular'
        category_totals_of_standard_expenses('spend_categories.identifier')
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

    # here I am grouping a column, and then each of those groups within that column get a "group_identifier"
    def category_totals_of_standard_expenses(column_name)
      case @only_needs_or_only_wants
      when 'only_needs'
        where_condition = { 'spend_categories.is_needed': true }
      when 'only_wants'
        where_condition = { 'spend_categories.is_needed': false }
      end

      base_spends = @spend_account.spends
                             .is_standard_expense
                             .in_month_and_year(@month, @year)
                             .joins(:spend_category)
                             .where(where_condition)
                             .distinct

      grouped_spends_value_hash = base_spends
                                  .group(column_name)
                                  .sum(:amount)

      results = grouped_spends_value_hash.map do |group_identifier, value|

        category_ids = find_category_ids_within_group(column_name, group_identifier)

        goal = aggregate_goals_for_categories(category_ids, where_condition)
        {
          identifier: group_identifier,
          label: calculate_label(column_name, group_identifier),
          goal:,
          value: value.abs.to_f.round(2),
          percentage: (value.abs / standard_expense_gross_total.abs * 100).round(2),
          list_of_included_categories: SpendCategory.where(id: category_ids).pluck(:name)
        }
      end

      if column_name != 'spend_categories.is_needed'
        results.sort_by { |result| result[:identifier] }
      else
        results
      end
    end

    def standard_expense_gross_total
      @spend_account.spends
                    .is_standard_expense
                    .in_month_and_year(@month, @year)
                    .sum(:amount)
    end

    def aggregate_goals_for_categories(category_ids, where_condition)
      @spend_account.goals
                    .joins(:spend_category)
                    .where(month: @month, year: @year, spend_category_id: category_ids)
                    .where(where_condition)
                    .sum(:target_value)
    end

    # grab all of the categories that fit the identifier
    def find_category_ids_within_group(column_name, column_name_identifier, inverse: false)
      if inverse
        SpendCategory.where.not(column_name => column_name_identifier).pluck(:id)
      else
        SpendCategory.where(column_name => column_name_identifier).pluck(:id)
      end
    end

    def calculate_label(column_name, column_name_identifier)
      case column_name
      when 'spend_categories.is_needed'
        column_name_identifier ? 'needs' : 'wants'
      when 'spend_categories.is_standard_expense'
        'all_standard_expenses'
      else
        column_name_identifier.to_s.humanize
      end
    end
  end
end
