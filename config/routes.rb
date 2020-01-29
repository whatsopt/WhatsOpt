Rails.application.routes.draw do

  devise_for :users
  resources :users, only: [:show]
  resource :api_doc, only: [:show]

  resources :analyses, shallow: true, as: :mdas do
    resources :operations do
      resources :meta_models, only: [:show, :create]        
      get 'exports/new', to: 'operation_exports#new'
    end
    get 'exports/new', to: 'analysis_exports#new'
  end
    
  namespace :api do
    namespace :v1, defaults: { format: :json } do
      resource :api_doc, only: [:show]
      resources :analyses, shallow: true, as: :mdas, only: [:index, :show, :create, :update] do
        resource :analysis_discipline, as: :discipline, only: [:create]
        resources :disciplines, only: [:show, :create, :update, :destroy], shallow: true do
          resource :analysis_discipline, as: :mda, only: [:create, :destroy]
        end
        resources :connections, only: [:create, :update, :destroy]
        resources :operations, only: [:show, :create, :update, :destroy] do
          resource :job, only: [:show, :create, :update]        
          resources :meta_models, only: [:create, :update] do
            resource :prediction_quality, only: [:show]
          end       
          resource :sensitivity_analysis, only: [:show]
        end
        resource :openmdao_impl, only: [:show, :update]
        resource :parameterization, only: [:update]
        post 'openmdao_checking', to: 'openmdao_checking#create' 
        get 'exports/new'
      end
      resources :operations, only: [:create]
      resources :users, only: [:index, :update]  
      resources :user_roles, only: [:index, :update]  
      resource :versioning, only: [:show]  
    end
  end

  get '/changelog' => 'infos#changelog'
  
  authenticated :user do
    root to: 'analyses#index', as: :authenticated_root
  end
  root to: redirect('users/sign_in')

end
