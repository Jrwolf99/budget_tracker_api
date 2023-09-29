# frozen_string_literal: true

module Api
  module V1
    class GoalsController < ApplicationController
      def create_or_update_goal
        my_spend_account = get_spend_account(params[:user_id])
        spend_category_id = SpendCategory.find_by(identifier: params[:spend_category_identifier]).id

        my_goal = my_spend_account.goals.find_or_initialize_by(month: params[:month],
                                                               year: params[:year],
                                                               spend_category_id:
                                                              )
        my_goal.target_value = params[:target_value]

        if my_goal.save!
          render json: my_goal, status: :ok
        else
          render json: my_goal.errors, status: :unprocessable_entity
        end
      end
    end
  end
end
