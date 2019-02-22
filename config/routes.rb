Rails.application.routes.draw do
  namespace :api do
    namespace :v1 do
      resources :users
      resources :medications
      resources :interactions
      resources :search
    end
  end
end
