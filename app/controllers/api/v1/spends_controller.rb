class Api::V1::SpendsController < ApplicationController

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


        puts "
        
        here is my params: #{params}
        
        "

        my_spend_category_id = SpendCategory.find_by(identifier: params[:spend_category])&.id
        
        puts "
        
        here is my spend category id: #{my_spend_category_id}
        
        "



        if my_spend.update!(spend_category_id: my_spend_category_id)
            render json: my_spend
        else
            render json: my_spend.errors, status: :unprocessable_entity
        end
    end
end