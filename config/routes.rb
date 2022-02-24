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
    resources :products do
      collection do
        post :delete_selected
      end
    end

    get '/dashboard/index' , to: 'dashboard#index'
    get '/dashboard/user', to: 'dashboard#user'
    get '/dashboard/user_edit', to: 'dashboard#user_edit'
    get '/dashboard/test_email', to: 'dashboard#test_email'

  end # constraints

  devise_for :users, controllers: {
    registrations:  'users/registrations',
    sessions:       'users/sessions',
    passwords:      'users/passwords',
  }

  resources :users do
    collection do
      delete '/:id/images/:image_id', action: 'delete_image', as: 'delete_image'
    end
  end

end
