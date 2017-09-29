Rails.application.routes.draw do
  
  resources :variables
  resources :disciplines
  resources :multi_disciplinary_analyses, as: :mdas do
    get "openmdao_generation/new"
  end
  devise_for :users
  resources :users, only: [:show]
  resources :projects
  resources :studies
  resources :notebooks
  resources :attachments, only: [:show, :index]
  resources :openmdao_generation, only: [:new]
    
  namespace :api do
    namespace :v1, defaults: { format: :json } do
      resources :studies
      post "openmdao_checking", to: "openmdao_checking#create" 
    end
  end

  get "/jupyterhub" => redirect("https://rdri206h.onecert.fr")
  get "/oneramdao" => redirect("http://dcps.onera/redmine/projects/oneramdao/files")
  get "/changelog" => 'infos#changelog'
  
  authenticated :user do
    root to: 'multi_disciplinary_analyses#index', as: :authenticated_root
  end
  root to: redirect('users/sign_in')
  
end
