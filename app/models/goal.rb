class Goal < ApplicationRecord
    belongs_to :category
  
    validates :category_id, uniqueness: { scope: [:month, :year],
      message: "should have one goal per category per month/year" }
  
    def total_spent
      category.transactions.where(month:, year:).sum(:amount)
    end
    
  end
  