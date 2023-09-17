# frozen_string_literal: true

class Goal < ApplicationRecord
  belongs_to :spend_account

  validates_uniqueness_of :month, scope: %i[year user_id],
                                  message: 'You already have a goal set for this month and year.'
end
