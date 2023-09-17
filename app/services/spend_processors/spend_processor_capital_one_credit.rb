# frozen_string_literal: true

require 'csv'

module SpendProcessors
  class SpendProcessorCapitalOneCredit < SpendProcessors::RootSpendProcessor
    def process_row(row)
      return if row['Transaction Date'].blank?

      if row['Debit'].present?
        amount = row['Debit'].to_f * -1
      elsif row['Credit'].present?
        amount = row['Credit'].to_f
      end

      my_spend = Spend.find_or_initialize_by(
        spend_account_id: spend_account.id,
        amount:,
        description: row['Description'],
        date_of_spend: Date.strptime(row['Transaction Date'], '%Y-%m-%d')
      )
      if my_spend.new_record?
        my_spend.save!
        @created_count += 1
      else
        @duplicate_count += 1
      end
    end
  end
end
