# frozen_string_literal: true

module Api
  module V1
    class SpendsController < ApplicationController
      def update
        my_spend = Spend.find(spend_params[:id])

        update_spend_category(my_spend) if params[:spend_category].present?

        if my_spend.update(spend_params)
          my_spend.update(locked_from_importer_at: Time.now) if spend_params[:date_of_spend].present?
          render json: my_spend
        else
          render json: my_spend.errors, status: :unprocessable_entity
        end
      end

      def ai_categorize
        spends = Spend.where(spend_category_id: nil, id: params[:spend_ids])

        if spends.no_ai_suggested_spend_category.count.zero?
          render json: { message: 'No spends to categorize' }
          return
        end

        response_schema = {
          type: 'ARRAY',
          items: {
            type: 'OBJECT',
            properties: {
              spend_id: { type: 'STRING' },
              category_identifier: { type: 'STRING' }
            }
          }
        }

        ai_asker = Ai::AiAsker.new
        spend_categories = SpendCategory.pluck(:identifier, :id).to_h

        question_prompt = <<~PROMPT
          Categories: [#{spend_categories.keys.join(', ')}]
          Spends: #{spends.no_ai_suggested_spend_category.map { |spend| { id: spend.id, desc: spend.description } }.to_json}
          Assign each spend an appropriate category.
        PROMPT

        response = ai_asker.ask_gpt(question_prompt, response_schema)

        response_json = JSON.parse(response[0]['parts'][0]['text'])

        response_json.each do |response_item|
          spend_id = response_item['spend_id']
          category_identifier = response_item['category_identifier']
          spend = spends.find { |s| s.id == spend_id.to_i }
          spend.update(ai_suggested_spend_category_id: spend_categories[category_identifier])
        end

        render json: { message: 'Spends categorized' }
      end

      private

      def update_spend_category(my_spend)
        spend_category = SpendCategory.find_by(identifier: spend_category_params[:identifier])
        my_spend.update(spend_category_id: spend_category.id)
      end

      def spend_params
        params.require(:spend).permit(:id, :date_of_spend, :amount, :notes)
      end

      def spend_category_params
        params.require(:spend_category).permit(:identifier)
      end
    end
  end
end
