Rails.application.routes.draw do

  devise_for :users
  resources :users, only: [:show]
  
  resources :variables
  resources :analyses, shallow: true, as: :mdas do
    resources :operations, except: [:new]
    get 'exports/new'
  end
  resources :notebooks
  resources :geometry_models
  resources :attachments, only: [:show, :index]
    
  namespace :api do
    namespace :v1, defaults: { format: :json } do
      resources :analyses, shallow: true, as: :mdas, only: [:index, :show, :create, :update] do
        resources :disciplines, only: [:show, :create, :update, :destroy], :shallow => true 
        resources :connections, only: [:create, :update, :destroy]
        resources :operations, only: [:show, :create, :update, :destroy] do
          resource :job, only: [:show, :create, :update]
        end
        post 'openmdao_checking', to: 'openmdao_checking#create' 
        get 'exports/new'
      end
      resources :users, only: [:index, :update]  
      resource :versioning, only: [:show]  
    end
  end

  get '/toolbox' => redirect('http://dcps.onera/redmine/projects/oneramdao/files')
  get '/issues' => redirect('http://dcps.onera/redmine/projects/whatsopt/issues')
  get '/wiki' => redirect('http://dcps.onera/redmine/projects/whatsopt/wiki')
  get '/changelog' => 'infos#changelog'
  
  authenticated :user do
    root to: 'analyses#index', as: :authenticated_root
  end
  root to: redirect('users/sign_in')
  
  #mount ActionCable.server => '/cable'
end
