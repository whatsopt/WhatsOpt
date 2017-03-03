Rails.application.routes.draw do
  
  resources :variables
  resources :disciplines
  resources :multi_disciplinary_analyses
  devise_for :users

  resources :users, only: [:show]
  resources :projects
  resources :studies
  resources :notebooks
  resources :attachments, only: [:show, :index]

  namespace :api do
    namespace :v1 do
      resources :studies
    end
  end

  authenticated :user do
    root to: 'projects#index', as: :authenticated_root
  end
  root to: redirect('users/sign_in')
  
end
