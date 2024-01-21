# frozen_string_literal: true

class SpendSerializer < ActiveModel::Serializer
  attributes :id, :date_of_spend, :amount, :description, :notes, :last_four

  belongs_to :spend_category
end
