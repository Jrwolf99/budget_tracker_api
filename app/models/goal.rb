# frozen_string_literal: true

class Goal < ApplicationRecord
  belongs_to :spend_account
  belongs_to :spend_category

  validates_uniqueness_of :month, scope: %i[month year spend_category_id spend_account_id],
                                  message: 'You already have a goal set for this month and year.'

  scope :with_category_identifier, lambda { |identifier|
                                     if identifier == 'all'
                                       all
                                     elsif identifier == 'uncategorized'
                                       where(spend_category_id: nil)
                                     else
                                       where(spend_category_id: SpendCategory.find_by_identifier(identifier)&.id)
                                     end
                                   }
end
