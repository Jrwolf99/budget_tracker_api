class TransactionSerializer < ActiveModel::Serializer
  attributes :id, :description, :amount, :transaction_date, :notes, :category_id

end
