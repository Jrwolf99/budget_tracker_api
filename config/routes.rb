Rails.application.routes.draw do


  namespace :api do
    namespace :v1 do

      resources :transactions, only: [:index]
      post '/transactions/upload', to: 'transactions#upload'
      put '/transactions/update_row_notes', to: 'transactions#update_row_notes'
      put '/transactions/update_row_category', to: 'transactions#update_row_category'
      get '/transactions/category_detailed_list', to: 'transactions#category_detailed_list'



      resources :categories, only: [:index]
    end
  end



end
