require 'csv'
require 'rack'

class Api::V1::TransactionsController < ApplicationController
 
  def index
    puts "params: #{params}"
    case params[:category_id]
    when 'all'
      transactions = Transaction.order(transaction_date: :desc).where(month: params[:month], year: params[:year])
    when 'uncategorized'
      transactions = Transaction.order(transaction_date: :desc).where(month: params[:month], year: params[:year], category_id: nil)
    else
      transactions = Transaction.order(transaction_date: :desc).where(month: params[:month], year: params[:year], category_id: params[:category_id])
    end

    render json: transactions,
    each_serializer: TransactionSerializer, 
    status: :ok
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
        begin
          next if transaction_date.year < 2022
          year = transaction_date.year
          month = transaction_date.month
          Transaction.create(description:, amount:, transaction_date:, year:, month: )
        rescue ActiveRecord::RecordNotUnique => e
          puts "Skipping duplicate transaction: #{description}, #{amount}, #{transaction_date}"
        end
      end
      render json: { message: 'CSV file uploaded and processed successfully' }
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
                                              .where.not(category_id:5)
                                              .where.not(category_id: 8)
                                              .where.not(category_id: 11)
                                              .where.not(category_id: 12)
                                              .sum(:amount).abs.to_f


    totals_by_category = Transaction.where(month: params[:month], year: params[:year])
                                    .where.not(category_id: 5)
                                    .where.not(category_id: 8)
                                    .where.not(category_id: 11)
                                    .where.not(category_id: 12)
                                    .group(:category_id)
                                    .sum(:amount)
  
    result = totals_by_category.map do |category_id, value|
      
      goal = Goal.find_by(month: params[:month], year: params[:year], category_id: category_id)&.goal_amount.to_f
      absolute_value = value.abs.to_f
      percentage = (absolute_value / total_monthly_expense_amount * 100).round(0)
  
      { 
        category: Category.find(category_id).category_name,
        value: absolute_value,
        goal: goal,
        percentage: percentage || 0
      }
    end
  
    render json: result.sort_by { |item| item[:percentage] }
  end
  



end
