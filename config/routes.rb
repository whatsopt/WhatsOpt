Rails.application.routes.draw do
  devise_for :users
  resources :users, only: [:show]
  resource :api_doc, only: [:show]

  resources :analyses, shallow: true, as: :mdas do
    resources :operations do
      get 'exports/new', to: 'operation_exports#new'
    end
    get 'exports/new', to: 'analysis_exports#new'
  end
     
  resources :design_projects
  if APP_CONFIG['enable_fastoad']
    resources :fastoad_configs, shallow: true do
      resources :fastoad_modules
    end
  end 
  resources :packages, only: [:index, :destroy] if APP_CONFIG['enable_wopstore']

  resources :optimizations do
    collection do
      post 'select'
      get 'compare'
    end
    get 'download', to: 'optimization_exports#new'
  end

  namespace :api do
    namespace :v1, defaults: { format: :json } do
      resource :api_doc, only: [:show]
      resources :analyses, shallow: true, as: :mdas, only: [:index, :show, :create, :update] do
        resources :disciplines, only: [:index, :create, :update, :destroy], shallow: false
        resources :connections, only: [:create, :update, :destroy], shallow: false
        resources :operations, only: [:show, :create, :update, :destroy] do
          resource :job, only: [:show, :create, :update] if APP_CONFIG['enable_remote_operations']        
          resources :meta_models, only: [:create, :update] do
            resource :prediction_quality, only: [:show]
          end       
          resource :sensitivity_analysis, only: [:show]
        end
        resource :openmdao_impl, only: [:show, :update]
        resource :parameterization, only: [:update]
        resource :journal, only: [:show]        
        resource :package, only: [:show, :create] if APP_CONFIG['enable_wopstore']
        post 'openmdao_checking', to: 'openmdao_checking#create' 
        get 'exports/new'
        get 'comparisons/new'
      end
      resources :meta_models, only: [:index, :show]
      resources :operations, only: [:create] if APP_CONFIG['enable_remote_operations']
      resources :users, only: [:update] do
        resource :api_key
      end
      resources :user_roles, only: [:index, :update, :destroy]  
      resource :versioning, only: [:show]  
      resources :optimizations
      resources :design_projects, only: [:index, :show, :create]
    end
  end

  get '/changelog' => 'infos#changelog'
  
  authenticated :user do
    root to: 'analyses#index', as: :authenticated_root
  end
  root to: redirect('users/sign_in')

  mount Rswag::Api::Engine => '/api_doc'
end
