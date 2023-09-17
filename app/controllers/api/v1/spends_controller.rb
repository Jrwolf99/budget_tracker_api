# frozen_string_literal: true

module Api
  module V1
    class SpendsController < ApplicationController
      def update_spend_notes
        my_spend = Spend.find(params[:spend_id])
        if my_spend.update(notes: params[:notes])
          render json: my_spend
        else
          render json: my_spend.errors, status: :unprocessable_entity
        end
      end

      def update_spend_category
        my_spend = Spend.find(params[:spend_id])
        my_spend_category_id = SpendCategory.find_by(identifier: params[:spend_category])&.id
        if my_spend.update!(spend_category_id: my_spend_category_id)
          render json: my_spend
        else
          render json: my_spend.errors, status: :unprocessable_entity
        end
      end
    end
  end
end
