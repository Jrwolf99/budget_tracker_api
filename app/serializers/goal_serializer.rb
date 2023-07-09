class GoalSerializer < ActiveModel::Serializer
    attributes :id, :goal_amount, :category_name, :category_id
  
    def category_name
      object&.category&.category_name
    end
  

end