# frozen_string_literal: true

module Api
  module V1
    class SpendsController < ApplicationController
      def update
        my_spend = Spend.find(spend_params[:id])

        if my_spend.update(spend_params)
          my_spend.update(locked_from_importer_at: Time.now) if spend_params[:date_of_spend].present?
          render json: my_spend
        else
          render json: my_spend.errors, status: :unprocessable_entity
        end
      end

      private

      def spend_params
        params.require(:spend).permit(:id, :spend_category_id, :date_of_spend, :amount, :notes)
      end
    end
  end
end
