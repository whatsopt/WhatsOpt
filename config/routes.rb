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

  resources :optimizations do
    collection do
      post 'select'
      get 'compare'
    end
    get 'download' => 'optimizations#download'
  end

  namespace :api do
    namespace :v1, defaults: { format: :json } do
      resource :api_doc, only: [:show]
      resources :analyses, shallow: true, as: :mdas, only: [:index, :show, :create, :update] do
        resources :disciplines, only: [:index, :create, :update, :destroy], shallow: false
        resources :connections, only: [:create, :update, :destroy], shallow: false
        resources :operations, only: [:show, :create, :update, :destroy] do
          resource :job, only: [:show, :create, :update]        
          resources :meta_models, only: [:create, :update] do
            resource :prediction_quality, only: [:show]
          end       
          resource :sensitivity_analysis, only: [:show]
        end
        resource :openmdao_impl, only: [:show, :update]
        resource :parameterization, only: [:update]
        resource :journal, only: [:show]        
        post 'openmdao_checking', to: 'openmdao_checking#create' 
        get 'exports/new'
        get 'comparisons/new'
      end
      resources :meta_models, only: [:index, :show]
      resources :operations, only: [:create]
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
