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
  get '/insints' , to: 'home#index'
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
    end
  end

  # get '/insints/install' , to: 'insints#install'
  # get '/insints/uninstall' , to: 'insints#uninstall'
  # get '/insints/login' , to: 'insints#login'
  # get '/insints/addizb' , to: 'insints#addizb'
  # get '/insints/getizb' , to: 'insints#getizb'
  # get '/insints/deleteizb' , to: 'insints#deleteizb'
  # get '/insints' , to: 'home#index'
  # get '/insints/new' , to: 'insints#new'
  # get '/insints/:id/edit' , to: 'insints#edit'
  # get '/insints/adminindex' , to: 'insints#adminindex'

  constraints SubdomainConstraint do
    resources :useraccounts
    resources :clients
    resources :invoices do
      get :print
    end
    resources :companies
    get '/dashboard/index' , to: 'dashboard#index'
    get '/dashboard/users', to: 'dashboard#users'
    delete '/dashboard/user_destroy', to: 'dashboard#user_destroy'
  end # constraints

  devise_for :users, controllers: {
    registrations:  'users/registrations',
    sessions:       'users/sessions',
    passwords:      'users/passwords',
  }

  # For details on the DSL available within this file, see http://guides.rubyonrails.org/routing.html
end
