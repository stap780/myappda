Rails.application.routes.draw do

  require 'sidekiq/web'

  authenticate :user, ->(user) { user.admin? } do
    mount Sidekiq::Web => '/sidekiq'
  end

  resources :payments do
    collection do
      post :success
      post :fail
      post :result
    end
  end
  resources :payplans

  root to: 'home#index'
  get "/documents", to: "home#documents"
  get "/favorite", to: "home#favorite"
  get "/restock", to: "home#restock"
  get "/message", to: "home#message"
  get "/oferta", to: "home#oferta"
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
      get :addrestock
      post :order
    end
  end

  constraints SubdomainConstraint do
    resources :order_status_changes
    resources :message_setups
    resources :event_actions
    resources :templates do
      collection do
        get '/:id/preview', action: 'preview', as: 'preview'
      end
    end
    resources :events
    resources :email_setups
    resources :favorite_setups
    resources :restock_setups
    resources :useraccounts
    get '/clients/:id/emailizb', to: 'clients#emailizb', as: 'emailizb_client'
    resources :clients do
      collection do
        get :otchet
      end
    end
    resources :invoices do
      get :print
    end
    resources :companies
    resources :products do
      collection do
        post :delete_selected
      end
    end
    resources :variants
    get '/dashboard', to: 'dashboard#index'
    get '/dashboard/test_email', to: 'dashboard#test_email'
    get '/dashboard/services', to: 'dashboard#services'
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
