Rails.application.routes.draw do
  
  resources :variables
  resources :analyses, as: :mdas do
    get 'exports/new'
  end
  devise_for :users
  resources :users, only: [:show]
  resources :projects
  resources :notebooks
  resources :geometry_models
  resources :attachments, only: [:show, :index]
  resources :operations, only: [:show, :index]  
    
  namespace :api do
    namespace :v1, defaults: { format: :json } do
      resources :analyses, shallow: true, as: :mdas, only: [:index, :show, :create, :update] do
        resources :disciplines, only: [:show, :create, :update, :destroy], :shallow => true 
        resources :connections, only: [:create, :update, :destroy]
        post 'openmdao_checking', to: 'openmdao_checking#create' 
        get 'exports/new'
      end
    end
  end

  #get '/jupyterhub' => redirect('https://rdri206h.onecert.fr')
  get '/toolbox' => redirect('http://dcps.onera/redmine/projects/oneramdao/files')
  get '/issues' => redirect('http://dcps.onera/redmine/projects/whatsopt/issues')
  get '/wiki' => redirect('http://dcps.onera/redmine/projects/whatsopt/wiki')
  get '/changelog' => 'infos#changelog'
  
  authenticated :user do
    root to: 'analyses#index', as: :authenticated_root
  end
  root to: redirect('users/sign_in')
  
end
