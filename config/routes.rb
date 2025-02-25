# frozen_string_literal: true

Rails.application.routes.draw do
  namespace :api do
    namespace :v1 do
      namespace :authentications do
        post 'sign_in', to: 'sessions#create'
        delete 'sign_out', to: 'sessions#destroy'
        post 'sign_up', to: 'registrations#create'

        namespace :sessions do
          get 'index'
          get 'show'
          delete 'destroy'
        end

        namespace :users do
          get 'show'
          patch 'update'
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

        namespace :password_resets do
          get 'edit'
          post 'create'
          patch 'update'
        end
      end

      namespace :spend_categories do
        get 'show_spend_categories_all'
        get 'show_spend_categories_standard_expenses'
      end

      namespace :spends do
        get 'index'
        put 'update'
        post 'upload'
        get 'years_overview_report'
        get 'totals_by_category_report'
        post 'ai_categorize'
      end

      namespace :spend_accounts do
        get 'show'
        put 'update'
      end

      namespace :goals do
        post 'create_or_update_goal'
      end
    end
  end
end
