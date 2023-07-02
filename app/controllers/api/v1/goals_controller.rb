class Api::V1::GoalsController < ApplicationController

    def index
        goals = Goal.all
        render json: goals
    end

    def set_goal
        goal = Goal.find_or_create_by(month: params[:month], year: params[:year], category_id: params[:category_id])
        goal.update(goal_params)
        render json: goal
    end
end
