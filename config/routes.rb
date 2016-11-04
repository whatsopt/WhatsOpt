Rails.application.routes.draw do
  
  devise_for :users
  
  resources :projects
  resources :studies
  resources :runs

  namespace :api do
    namespace :v1 do
      resources :studies
    end
  end

  authenticated :user do
    root to: 'studies#index', as: :authenticated_root
  end
  root to: redirect('/users/sign_in')
  
end
