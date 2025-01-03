# frozen_string_literal: true

require 'csv'

module SpendProcessors
  class SpendProcessorCapitalOneChecking < SpendProcessors::RootSpendProcessor
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
      my_date = Date.strptime(row['Transaction Date'], '%m/%d/%y')
      my_description = row['Transaction Description']
      my_last_four = row['Account Number']

      my_amount = if row['Transaction Type'] == 'Debit'
                    row['Transaction Amount'].to_f.abs * -1
                  else
                    row['Transaction Amount'].to_f.abs
                  end

      save_spend(my_date, my_amount, my_description, my_last_four)
    end
  end
end
