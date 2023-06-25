require 'csv'

class Api::V1::TransactionsController < ApplicationController
  def index
    transactions = Transaction.all
    render json: transactions
  end

  def create
    transactions = []
    CSV.foreach(params[:file].path, headers: true) do |row|
      transaction_hash = {
        description: row['Description'],
        amount: row['Amount'],
        category: row['Category']
      }
      transactions << Transaction.new(transaction_hash)
    end
    Transaction.import transactions
    render json: { message: 'Transactions created successfully' }, status: :created
  end
  
end
