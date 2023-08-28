Rails.application.routes.draw do


  namespace :api do
    namespace :v1 do

      namespace :transactions do
        get 'get_list_of_categories_with_monthly_expenses'
        get 'get_overview_report'
      end

      namespace :categories do
        get 'index'
      end
      
      namespace :goals do
        get 'index'
        post 'update_or_create_goal'
      end

      namespace :overview do
        get 'get_report'
      end

    end
  end
end


