# frozen_string_literal: true

require 'csv'
require 'nokogiri'

class SpendAccount < ApplicationRecord
  belongs_to :user
  has_many :goals
  has_many :spends

  def upload_spends(file)
    if file.original_filename.split('.').last == 'qbo'
      return SpendProcessors::SpendProcessorQbo.new(file, self).create_spends
    end

    # TODO: clean up code! if it isnt qbo, assume it is a CSV. At the moment, front end can only use QBO, so 
    # assume that the rest of the code in this method will never be reached. 
    # honestly, I could delete the two bank dependent spend processors, and just use QBO files. 
    csv_source = calculate_csv_source(file)
    raise 'wrong csv source' if csv_source == 'wrong_csv_source'

    case csv_source
    when 'capital_one_checking'
      SpendProcessors::SpendProcessorCapitalOneChecking.new(file, self).create_spends
    when 'capital_one_credit'
      SpendProcessors::SpendProcessorCapitalOneCredit.new(file, self).create_spends
    end
  end

  def show_spends(conditions)
    spends.in_month_and_year(conditions[:month],
                             conditions[:year]).with_category_identifier(conditions[:spend_category_identifier])
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
