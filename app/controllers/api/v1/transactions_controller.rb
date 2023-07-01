require 'csv'
require 'rack'

class Api::V1::TransactionsController < ApplicationController
  def index
    transactions = Transaction.all
    render json: transactions.order(transaction_date: :desc), each_serializer: TransactionSerializer, status: :ok
  end

  def upload
    uploaded_file = params[:file]

    if uploaded_file.content_type == 'text/csv'
      csv_data = uploaded_file.read
      csv = CSV.parse(csv_data, headers: true)
      csv.each do |row|
        description = row['Transaction Description']
        amount = row['Transaction Amount']
        transaction_date = Date.strptime(row['Transaction Date'], '%m/%d/%y')
        puts transaction_date
        category = row['Category']
        notes = row['Notes']
        begin
          next if transaction_date.year < 2022

          year = transaction_date.year
          month = transaction_date.month

          Transaction.create(description: description, amount: amount, transaction_date: transaction_date, category: category, notes: notes, year: year, month: month)
       
        rescue ActiveRecord::RecordNotUnique => e
          puts "Skipping duplicate transaction: #{description}, #{amount}, #{transaction_date}"
        end
      end
      render json: { message: 'CSV file uploaded and processed successfully' }
    else
      render json: { error: 'Invalid file format. Please upload a CSV file.' }, status: :unprocessable_entity
    end
  end

  def update_row_notes
    transaction = Transaction.find(params[:id])
    transaction.update!(notes: params[:notes])
    render json: { message: 'Notes updated successfully' }
  end

  def update_row_category
    transaction = Transaction.find(params[:id])
    transaction.update!(category: params[:category])
    render json: { message: 'Category updated successfully' }
  end

end
