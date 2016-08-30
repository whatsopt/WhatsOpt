Rails.application.routes.draw do
  
  devise_for :users
  
  resources :users
  resources :projects
  resources :studies
  resources :runs
  
  root to: 'projects#index'

end
