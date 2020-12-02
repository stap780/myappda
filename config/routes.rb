Rails.application.routes.draw do
  root to: 'home#index'
  get "/index-setup", to: "home#index_setup"

  namespace :admin do
    get '/account/index' , to: 'account#index'
    get '/account/switch_to_tenant' , to: 'account#switch_to_tenant'
  end

  constraints SubdomainConstraint do
    resources :payments do
      collection do
        post :success
        post :fail
        post :result
      end
    end
    resources :payplans
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
    resources :useraccounts
    get '/clients/otchet', to: 'clients#otchet'
    resources :clients
    resources :invoices do
      get :print
    end
    resources :companies
    get '/dashboard/index' , to: 'dashboard#index'
    get '/dashboard/users', to: 'dashboard#users'
    get '/dashboard/test_email', to: 'dashboard#test_email'
    delete '/dashboard/user_destroy', to: 'dashboard#user_destroy'
  end # constraints

  devise_for :users, controllers: {
    registrations:  'users/registrations',
    sessions:       'users/sessions',
    passwords:      'users/passwords',
  }

  # For details on the DSL available within this file, see http://guides.rubyonrails.org/routing.html
end
