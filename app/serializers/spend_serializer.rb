# frozen_string_literal: true

class SpendSerializer < ActiveModel::Serializer
  attributes :id, :date_of_spend, :amount, :description, :notes, :last_four, :ai_suggested_spend_category_identifier

  belongs_to :spend_category

  def ai_suggested_spend_category_identifier
    object.ai_suggested_spend_category&.identifier
  end
end
