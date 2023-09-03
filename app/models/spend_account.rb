class SpendAccount < ApplicationRecord
    belongs_to :user
    
    has_many :goals
    has_many :spends


end
