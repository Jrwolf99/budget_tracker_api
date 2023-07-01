class TransactionSerializer < ActiveModel::Serializer
  attributes :id, :description, :amount, :transaction_date, :notes, :category, :list_of_categories

end
