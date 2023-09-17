require 'csv'

class SpendAccount < ApplicationRecord
  belongs_to :user
  has_many :goals
  has_many :spends

  def upload_spends_through_CSV(file)
    csv_source = calculate_csv_source(file)
    raise 'wrong csv source' if csv_source == 'wrong_csv_source'

    case csv_source
    when 'capital_one_checking'
      SpendProcessors::SpendProcessorCapitalOneChecking.new(file, self).create_spends
    when 'capital_one_credit'
      SpendProcessors::SpendProcessorCapitalOneCredit.new(file, self).create_spends
    end
  end

  def years_overview_report(year)
    Reports::YearsOverviewReport.new(year, self).generate
  end

  def totals_by_category_report(year, month)
    Reports::TotalsByCategoryReport.new(year, month, self).generate
  end

  def show_spends(conditions)
    spend_category_identifier = conditions[:spend_category_identifier]

    if spend_category_identifier == 'all'
      spends.in_month_and_year(conditions[:month], conditions[:year])
    elsif spend_category_identifier == 'uncategorized'
      spends.in_month_and_year(conditions[:month], conditions[:year]).where(spend_category_id: nil)
    elsif spend_category_identifier.present?
      spends.in_month_and_year(conditions[:month], conditions[:year])
            .where(spend_category_id: SpendCategory.find_by_identifier(spend_category_identifier).id)
    else
      raise 'wrong spend_category_identifier'
    end
  end

  private

  def calculate_csv_source(file)
    CSV.open(file.path, headers: true) do |csv|
      hash = csv.first.to_hash
      return 'capital_one_checking' if hash['Account Number'].present?
      return 'capital_one_credit' if hash['Card No.'].present?
    end
    'wrong_csv_source'
  end
end
