# frozen_string_literal: true

module Api
  module V1
    class SpendCategoriesController < ApplicationController
      def show_spend_categories_all
        render json: SpendCategory.all
      end

      def show_spend_categories_standard_expenses
        render json: SpendCategory.where(is_standard_expense: true)
      end
    end
  end
end
