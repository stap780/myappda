Rails.application.routes.draw do

  resources :payments do
    collection do
      post :success
      post :fail
      post :result
    end
  end
  resources :payplans

  root to: 'home#index'
  get "/index-setup", to: "home#index_setup"
  # get '/insints' , to: 'home#index'
  resources :insints do
    collection do
      get :install
      get :uninstall
      get :login
      get :addizb
      get :getizb
      get :deleteizb
      get :adminindex
      get :setup_script
      get :delete_script
      get :checkint
      get :emailizb
    end
  end

  constraints SubdomainConstraint do
    resources :useraccounts
    get '/clients/otchet', to: 'clients#otchet'
    resources :clients
    resources :invoices do
      get :print
    end
    resources :companies
    resources :dashboard do
      collection do
          get :index
          get :users
          get :test_email
          get :client_count
          get :izb_count
          delete :user_destroy
      end
    end
    # get '/dashboard/index' , to: 'dashboard#index'
    # get '/dashboard/users', to: 'dashboard#users'
    # get '/dashboard/test_email', to: 'dashboard#test_email'
    # get '/dashboard/client_count', to: 'dashboard#client_count'
    # get '/dashboard/izb_count', to: 'dashboard#izb_count'
    # delete '/dashboard/user_destroy', to: 'dashboard#user_destroy'
  end # constraints

  devise_for :users, controllers: {
    registrations:  'users/registrations',
    sessions:       'users/sessions',
    passwords:      'users/passwords',
  }

  # For details on the DSL available within this file, see http://guides.rubyonrails.org/routing.html
end
