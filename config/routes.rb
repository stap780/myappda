Rails.application.routes.draw do

  root to: 'home#index'

  devise_for :users, controllers: {
    registrations:  'users/registrations',
    sessions:       'users/sessions',
    passwords:      'users/passwords',
  }

  constraints SubdomainConstraint do
    resources :insints do
      collection do
        get :install
        get :uninstall
        get :login
      end
    end
    get '/dashboard/index' , to: 'dashboard#index'
  end # constraints

  # For details on the DSL available within this file, see http://guides.rubyonrails.org/routing.html
end
