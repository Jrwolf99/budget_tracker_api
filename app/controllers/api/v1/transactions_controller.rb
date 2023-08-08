require 'csv'
require 'rack'

class Api::V1::TransactionsController < ApplicationController
  def index
    transactions = Transaction.order(transaction_date: :desc)

    transactions = case params[:category_identifier]
                   when 'all'
                     transactions.in_month_and_year(params[:month], params[:year])
                   when 'uncategorized'
                     transactions.in_month_and_year(params[:month], params[:year]).uncategorized
                   else
                     transactions.in_month_and_year(params[:month],
                                                    params[:year]).with_category(params[:category_identifier])
                   end

    render json: transactions,
           each_serializer: TransactionSerializer,
           status: :ok
  end

  def set_notes
    transaction = Transaction.find(params[:id])
    transaction.update!(notes: params[:notes])
    render json: { message: 'Notes updated successfully' }
  end

  def set_category
    transaction = Transaction.find(params[:id])
    transaction.update!(category_id: params[:category_id])
    render json: { message: 'Category updated successfully' }
  end

  def get_list_of_categories_with_monthly_expenses
    render json: Transaction.get_list_of_categories_with_monthly_expenses(
      params[:month],
      params[:year]
    ), status: :ok
  end

  def upload
    uploaded_file = params[:file]
  
    render json: { error: 'Invalid file format. Please upload a CSV file.' }, status: :unprocessable_entity unless uploaded_file.content_type == 'text/csv'

    errored_transactions, duplicate_transactions, total_count = process_csv(uploaded_file.read)
  
    message = generate_response_message(total_count, errored_transactions, duplicate_transactions)
    render json: { message: message }, status: :ok
  end

  private

  
  def process_csv(csv_data)
    errored_transactions = []
    duplicate_transactions = []
    total_count = 0
  
    CSV.parse(csv_data, headers: true).each do |row|
      next unless valid_transaction_date?(row['Transaction Date'])

      transaction = build_transaction_from_row(row)
      total_count += 1
  
      begin
        Transaction.create(transaction)
      rescue ActiveRecord::RecordNotUnique => e
        puts "Skipping duplicate transaction: #{transaction}"
        duplicate_transactions << transaction
      rescue StandardError => e
        puts "Error creating transaction: #{transaction}"
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
    
      if debit_amount != 0
        amount = -debit_amount
      else
        amount = credit_amount
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

  def generate_response_message(total_count, errored_transactions, duplicate_transactions)
    if errored_transactions.empty? && duplicate_transactions.empty?
      "CSV processed with no errors and no duplicates. Total count was #{total_count}."
    elsif errored_transactions.empty?
      "CSV processed with no errors but there were #{duplicate_transactions.count} duplicates. Total count was #{total_count}. Total count added was #{total_count - duplicate_transactions.count}."
    elsif duplicate_transactions.empty?
      "CSV processed with #{errored_transactions.count} errors and no duplicates. Total count was #{total_count}. Total count added was #{total_count - errored_transactions.count}."
    else
      "CSV processed with #{errored_transactions.count} errors and #{duplicate_transactions.count} duplicates. Total count was #{total_count}. Total count added was #{total_count - errored_transactions.count - duplicate_transactions.count}."
    end
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
