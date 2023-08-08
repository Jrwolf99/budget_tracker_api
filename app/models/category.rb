class Category < ApplicationRecord
  has_many :transactions
  has_many :goals

  scope :excluding_categories, lambda {
    excluded_identifiers = %w[refunds transfers income]
    where.not(identifier: excluded_identifiers)
  }
end
