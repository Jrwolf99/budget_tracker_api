class Api::V1::GoalsController < ApplicationController

    def index
        params[:month] = 0 if params[:month] == "all"
        goals = Goal.where(month: params[:month], year: params[:year])
        render json: goals,
        each_serializer: GoalSerializer,
        status: :ok
    end

    def update_or_create_goal
        goal = Goal.find_or_create_by(month: params[:month], year: params[:year], category_id: params[:category_id])
        goal.update(params.permit(:goal_amount))
        render json: goal
    end


end
