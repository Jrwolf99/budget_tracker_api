class SpendSerializer < ActiveModel::Serializer
  attributes :id, :date_of_spend, :amount, :description, :spend_category_identifier, :notes

  def spend_category_identifier
    object.spend_category&.identifier
  end
end
