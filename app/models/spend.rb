class Spend < ApplicationRecord
    belongs_to :spend_category, optional: true
    belongs_to :spend_account
end
