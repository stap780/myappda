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
  get "/index-setup" => "home#index_setup"

  get '/insints/install' , to: 'insints#install'
  get '/insints/uninstall' , to: 'insints#uninstall'
  get '/insints/login' , to: 'insints#login'
  get '/insints/addizb' , to: 'insints#addizb'
  get '/insints/getizb' , to: 'insints#getizb'
  get '/insints/deleteizb' , to: 'insints#deleteizb'
  get '/insints' , to: 'home#index'

  constraints SubdomainConstraint do
    resources :useraccounts
    resources :clients
    resources :invoices do
      get :print
    end
    resources :companies
    get '/dashboard/index' , to: 'dashboard#index'
  end # constraints

  devise_for :users, controllers: {
    registrations:  'users/registrations',
    sessions:       'users/sessions',
    passwords:      'users/passwords',
  }

  # For details on the DSL available within this file, see http://guides.rubyonrails.org/routing.html
end
