Rails.application.routes.draw do


  namespace :api do
    namespace :v1 do

      resources :transactions, only: [:index]
      post '/transactions/upload', to: 'transactions#upload'
      put '/transactions/set_notes', to: 'transactions#set_notes'
      put '/transactions/set_category', to: 'transactions#set_category'
      get '/transactions/category_detailed_list', to: 'transactions#category_detailed_list'
      get '/transactions/get_totals_by_category', to: 'transactions#get_totals_by_category'
      
      
      resources :categories, only: [:index]

      resources :goals, only: [:index]
      post '/goals/update_or_create_goal', to: 'goals#update_or_create_goal'

    end
  end



end
