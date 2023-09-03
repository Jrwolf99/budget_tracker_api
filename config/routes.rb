Rails.application.routes.draw do


  namespace :api do
    namespace :v1 do

      post "sign_in", to: "sessions#create"
      post "sign_up", to: "registrations#create"

      namespace :sessions do
        get 'index'
        get 'show'
        delete 'destroy'
      end

      namespace :password do
        get 'edit'
        patch 'update'
      end

      namespace :email do
        get 'edit'
        patch 'update'
      end

      namespace :email_verification do
        get 'show'
        post 'create'
      end

      namespace :password_reset do
        get 'new'
        get 'edit'
        post 'create'
        patch 'update'
      end

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


