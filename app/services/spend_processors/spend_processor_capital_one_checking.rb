# frozen_string_literal: true

require 'csv'

module SpendProcessors
  class SpendProcessorCapitalOneChecking < SpendProcessors::RootSpendProcessor
    def process_row(row)
      my_date = Date.strptime(row['Transaction Date'], '%m/%d/%y')
      my_description = row['Transaction Description']
      my_last_four = row['Account Number']

      my_amount = if row['Transaction Type'] == 'Debit'
                    -row['Transaction Amount'].to_f
                  else
                    row['Transaction Amount'].to_f
                  end

      save_spend(my_date, my_amount, my_description, my_last_four)
    end
  end
end
