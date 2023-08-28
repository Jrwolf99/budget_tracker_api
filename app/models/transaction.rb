class Transaction < ApplicationRecord
  belongs_to :category, optional: true
  scope :uncategorized, -> { where(category_id: nil) }
end

