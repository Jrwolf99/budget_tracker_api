require 'csv'

class SpendProcessors::SpendProcessorCapitalOneChecking < SpendProcessors::RootSpendProcessor
  def process_row(row)
    my_spend = Spend.find_or_initialize_by(
      spend_account_id: spend_account.id,
      amount: row['Transaction Amount'].to_f,
      description: row['Transaction Description'],
      date_of_spend: Date.strptime(row['Transaction Date'], '%m/%d/%y')
    )
    if my_spend.new_record?
      my_spend.save!
      @created_count += 1
    else
      @duplicate_count += 1
    end
  end
end
