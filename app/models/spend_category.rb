# frozen_string_literal: true

class SpendCategory < ApplicationRecord
    has_many :goals
end
