Rails.application.routes.draw do


  namespace :api do
    namespace :v1 do
      

      
      
      namespace :authentications do
        post "sign_in", to: "sessions#create"
        delete "sign_out", to: "sessions#destroy"
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
      end








    
  
   
    end
  end
end


