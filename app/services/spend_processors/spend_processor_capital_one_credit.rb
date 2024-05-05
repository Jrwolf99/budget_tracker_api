# frozen_string_literal: true

require 'csv'

module SpendProcessors
  class SpendProcessorCapitalOneCredit < SpendProcessors::RootSpendProcessor
    def process_row(row)
      return if row['Transaction Date'].blank?

      if row['Debit'].present?
        amount = row['Debit'].to_f.abs * -1
      elsif row['Credit'].present?
        amount = row['Credit'].to_f.abs
      end

      my_date = Date.strptime(row['Transaction Date'], '%Y-%m-%d')
      my_amount = amount
      my_description = row['Description']
      my_last_four = row['Card No.']

      save_spend(my_date, my_amount, my_description, my_last_four)
    end
  end
end
