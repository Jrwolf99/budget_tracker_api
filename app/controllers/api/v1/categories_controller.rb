class Api::V1::CategoriesController < ApplicationController

    def index
        categories = Category.all
        render json: categories.order(:name), each_serializer: CategorySerializer, status: :ok
    end

end
