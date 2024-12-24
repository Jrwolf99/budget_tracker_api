# frozen_string_literal: true

require 'csv'

module SpendProcessors
  class SpendProcessorCapitalOneCredit < SpendProcessors::RootSpendProcessor
    def create_spends
      @created_count = 0
      @duplicate_count = 0
      @locked_count = 0

      CSV.foreach(imported_file, headers: true) do |row|
        process_row(row)
      end
      { created_count: @created_count,
        duplicate_count: @duplicate_count,
        locked_count: @locked_count }
    end
  
    def process_row(row)
      return if row['Transaction Date'].blank?

      my_date = Date.strptime(row['Transaction Date'], '%Y-%m-%d')
      my_description = row['Description']
      my_last_four = row['Card No.']

      my_amount = if row['Debit'].present?
                    row['Debit'].to_f.abs * -1
                  elsif row['Credit'].present?
                    row['Credit'].to_f.abs
                  else
                    raise "No debit or credit amount found in row: #{row}"
                  end

      save_spend(my_date, my_amount, my_description, my_last_four)
    end
  end
end
