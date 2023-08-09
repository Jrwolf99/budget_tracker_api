class TransactionCsvProcessor
  def process_csv(csv_data)
    errored_transactions = []
    duplicate_transactions = []
    total_count = 0

    CSV.parse(csv_data, headers: true).each do |row|
      next unless valid_transaction_date?(row['Transaction Date'])

      transaction = build_transaction_from_row(row)
      total_count += 1

      begin
        Transaction.transaction do
          unique_attributes = transaction.slice(:description, :transaction_date, :year, :month)

          existing_transaction = Transaction.find_by(unique_attributes)

          if existing_transaction.nil?
            existing_transaction = Transaction.create!(transaction)
          else
            duplicate_transactions << transaction
          end
        end
      rescue StandardError => e
        puts "Error creating/updating transaction: #{transaction}"
        errored_transactions << transaction
      end
    end

    [errored_transactions, duplicate_transactions, total_count]
  end

  def build_transaction_from_row(row)
    description = row['Transaction Description'] || row['Description']

    if row['Transaction Amount']
      amount = row['Transaction Amount']
    else
      debit_amount = row['Debit'].to_f
      credit_amount = row['Credit'].to_f

      amount = if debit_amount != 0
                 -debit_amount
               else
                 credit_amount
               end
    end

    transaction_date = parse_transaction_date(row['Transaction Date'])
    year = transaction_date.year
    month = transaction_date.month

    { description:, amount:, transaction_date:, year:, month: }
  end

  def valid_transaction_date?(date)
    return false if date.nil? || date.empty?

    transaction_date = parse_transaction_date(date)
    transaction_date.year >= 2022
  end

  def parse_transaction_date(date_str)
    Date.strptime(date_str, '%Y-%m-%d')
  rescue StandardError
    begin
      Date.strptime(date_str, '%m/%d/%y')
    rescue StandardError
      nil
    end
  end
end
