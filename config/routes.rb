Rails.application.routes.draw do


  namespace :api do
    namespace :v1 do

      resources :transactions, only: [:index]
      post '/transactions/upload', to: 'transactions#upload'
      put '/transactions/set_notes', to: 'transactions#set_notes'
      put '/transactions/set_category', to: 'transactions#set_category'
      get '/transactions/category_detailed_list', to: 'transactions#category_detailed_list'
      get '/transactions/get_list_of_categories_with_monthly_expenses', to: 'transactions#get_list_of_categories_with_monthly_expenses'
      get '/transactions/get_overview_report', to: 'transactions#get_overview_report'

      resources :categories, only: [:index]

      resources :goals, only: [:index]
      post '/goals/update_or_create_goal', to: 'goals#update_or_create_goal'

    end
  end



end
