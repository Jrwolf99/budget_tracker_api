class Transaction < ApplicationRecord
    belongs_to :category, optional: true
end
