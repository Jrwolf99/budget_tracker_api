class Spend < ApplicationRecord
    belongs_to :spend_category
    belongs_to :spend_account
end
