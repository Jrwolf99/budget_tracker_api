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
                                                    params[:year]).where_category(params[:category_identifier])
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

  def get_overview_report
    render json: Transaction.get_overview_report(params[:year]), status: :ok
  end

  def upload
    uploaded_file = params[:file]
  
    render json: { error: 'Invalid file format. Please upload a CSV file.' }, status: :unprocessable_entity unless uploaded_file.content_type == 'text/csv'

    errored_transactions, duplicate_transactions, total_count = TransactionCsvProcessor.new.process_csv(uploaded_file.read)
  
    puts "Total count: #{total_count}"
    puts "Errored transactions: #{errored_transactions.count}"
    puts "Duplicate transactions: #{duplicate_transactions.count}"



    message = generate_response_message(total_count, errored_transactions, duplicate_transactions)
    render json: { message: message }, status: :ok
  end

  private

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

end