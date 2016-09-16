Rails.application.routes.draw do
  
  devise_for :users
  
  resources :users
  resources :projects
  resources :studies
  resources :runs

  namespace :api do
    namespace :v1 do
      resources :studies
    end
  end
  
  root to: 'studies#index'

end
