require 'csv'
require 'rack'

class Api::V1::TransactionsController < ApplicationController
  def index
    puts "params: #{params}"
    transactions = case params[:category_id]
                   when 'all'
                     Transaction.order(transaction_date: :desc).where(month: params[:month], year: params[:year])
                   when 'uncategorized'
                     Transaction.order(transaction_date: :desc).where(month: params[:month], year: params[:year],
                                                                      category_id: nil)
                   else
                     Transaction.order(transaction_date: :desc).where(month: params[:month], year: params[:year],
                                                                      category_id: params[:category_id])
                   end

    render json: transactions,
           each_serializer: TransactionSerializer,
           status: :ok
  end

  def upload
    uploaded_file = params[:file]
    errored_transactions = []
    duplicate_transactions = []
    total_count = 0

    if uploaded_file.content_type == 'text/csv'
      csv_data = uploaded_file.read
      csv = CSV.parse(csv_data, headers: true)
      csv.each do |row|
        description = row['Transaction Description'] || row['Description']
        amount = row['Transaction Amount'] || -row['Debit'] || 0.0
        transaction_date = parse_transaction_date(row['Transaction Date'])
        next if transaction_date.year < 2022

        year = transaction_date.year
        month = transaction_date.month

        total_count += 1
        begin
          Transaction.create(description:, amount:, transaction_date:, year:, month:)
        rescue ActiveRecord::RecordNotUnique => e
          puts "Skipping duplicate transaction: #{description}, #{amount}, #{transaction_date}"
          duplicate_transactions << { description:, amount:, transaction_date: }
        rescue StandardError => e
          puts "Error creating transaction: #{description}, #{amount}, #{transaction_date}"
          errored_transactions << { description:, amount:, transaction_date: }
        end
      end

      if errored_transactions.empty? && duplicate_transactions.empty?
        render json: { message: "CSV processed with no errors and no duplicates. Total count was #{total_count}." },
               status: :ok

      elsif errored_transactions.empty? && !duplicate_transactions.empty?
        render json: { message: "CSV processed with no errors but there were #{duplicate_transactions.count} duplicates. Total count was #{total_count}. Total count added was #{total_count - duplicate_transactions.count}." },
               status: :ok

      elsif !errored_transactions.empty? && duplicate_transactions.empty?
        render json: { message: "CSV processed with #{errored_transactions.count} errors and no duplicates. Total count was #{total_count}. Total count added was #{total_count - errored_transactions.count}." },
               status: :ok

      else
        render json: { message: "CSV processed with #{errored_transactions.count} errors and #{duplicate_transactions.count} duplicates. Total count was #{total_count}. Total count added was #{total_count - errored_transactions.count - duplicate_transactions.count}." },
               status: :ok
      end

    else
      render json: { error: 'Invalid file format. Please upload a CSV file.' }, status: :unprocessable_entity
    end
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

  def get_totals_by_category
    total_monthly_expense_amount = Transaction.where(month: params[:month], year: params[:year])
                                              .where.not(category_id: [5, 8, 11, 12])
                                              .sum(:amount).abs.to_f

    totals_by_category = Transaction.where(month: params[:month], year: params[:year])
                                    .where.not(category_id: [5, 8, 11, 12])
                                    .group(:category_id)
                                    .sum(:amount)

    result = totals_by_category.map do |category_id, value|
      goal = Goal.find_by(month: params[:month], year: params[:year], category_id:)&.goal_amount.to_f
      absolute_value = value.abs.to_f
      percentage = (absolute_value / total_monthly_expense_amount * 100).round(0)

      {
        category: Category.find(category_id).category_name,
        value: absolute_value,
        goal:,
        percentage: percentage || 0
      }
    end

    render json: result, status: :ok
  end

  private

  def parse_transaction_date(date_str)
    Date.strptime(date_str, '%Y-%m-%d')
  rescue ArgumentError
    begin
      Date.strptime(date_str, '%m/%d/%y')
    rescue ArgumentError
      nil
    end
  end
end
