Rails.application.routes.draw do
  namespace :api do
    namespace :v1 do
      resources :auth
      resources :users
      resources :user_medications
      resources :search
      resources :medications
      resources :interactions
      # resources :users #, only: [:create]
      get '/user/:id', to: 'users#user_medications'
      get '/user_interactions/:id', to: 'interactions#user_interactions'
      # post '/login', to: 'auth#create'
      # get '/current_user', to: 'auth#get_current_user'
      # get '/dashboard', to: 'users#dashboard'
    end
  end
end
