class TransactionSerializer < ActiveModel::Serializer
  attributes :id, :description, :amount, :transaction_date, :notes, :category_name, :category_id


  def category_name
    object&.category&.category_name
  end

end
