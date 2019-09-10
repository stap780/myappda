Rails.application.routes.draw do

  resources :useraccounts
  root to: 'home#index'

  get '/insints/install' , to: 'insints#install'
  get '/insints/uninstall' , to: 'insints#uninstall'
  get '/insints/login' , to: 'insints#login'


  devise_for :users, controllers: {
    registrations:  'users/registrations',
    sessions:       'users/sessions',
    passwords:      'users/passwords',
  }

  constraints SubdomainConstraint do
    get '/insints/index' , to: 'insints#index'
    get '/dashboard/index' , to: 'dashboard#index'
  end # constraints

  # For details on the DSL available within this file, see http://guides.rubyonrails.org/routing.html
end
