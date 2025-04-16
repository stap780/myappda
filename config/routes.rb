require 'sidekiq/web'
require 'sidekiq-scheduler/web'

Rails.application.routes.draw do

  authenticate :user, ->(user) { user.admin? } do
    mount Sidekiq::Web => '/sidekiq'
  end
  resources :payments do
    collection do
      post :success
      post :fail
      post :result
      post :delete_selected
    end
  end
  resources :payplans
  root to: 'home#index'
  get '/index-setup', to: 'home#favorite'
  get '/documents', to: 'home#documents'
  get '/favorite', to: 'home#favorite'
  get '/restock', to: 'home#restock'
  get '/message', to: 'home#message'
  get '/preorder', to: 'home#preorder'
  get '/abandoned_cart', to: 'home#abandoned_cart'
  get '/oferta', to: 'home#oferta'
  get '/disc', to: 'home#discount'
  resources :insints do
    collection do
      get '/:id/check', action: 'check', as: 'check'
      get :install # we use it for check service work when have request from clients json
      # get :uninstall
      # get :login
      get :addizb
      get :getizb
      get :deleteizb
      get :adminindex
      get :setup_script
      get :delete_script
      get :emailizb
      get :addrestock
      post :extra_data
      post :discount
      post :order
      post :abandoned_cart
      post :restock
      post :preorder
    end
  end

  constraints SubdomainConstraint do
    resources :discounts do
      member do
        patch :sort
      end
    end
    resources :lines
    resources :mycases do
      collection do
        post :bulk_delete
        post :csv_export
        post :download
      end
    end
    resources :order_status_changes
    resources :message_setups do
      collection do
        post :api_create_restock_xml
      end
    end
    resources :event_actions
    resources :templates do
      collection do
        get '/:id/preview_ins_order', action: 'preview_ins_order', as: 'preview_ins_order'
        get '/:id/preview_case', action: 'preview_case', as: 'preview_case'
        get '/:id/preview_restock', action: 'preview_restock', as: 'preview_restock'
      end
    end
    resources :events
    resources :email_setups
    resources :useraccounts
    resources :clients do
      member do
        get :emailizb
        get :update_from_insales
      end
      collection do
        get :otchet
        get :file_import_insales
        post :import
        post :import_insales_setup
        put :update_api_insales
        post :csv_export
        post :bulk_delete
        post :download
      end
    end
    resources :invoices do
      get :print
    end
    resources :companies
    resources :products do
      get :insales_info, on: :member
      collection do
        post :bulk_delete
        post :csv_export
        post :download
      end
    end
    resources :variants
    # get '/dashboard', to: 'dashboard#index'
    # get '/dashboard/test_email', to: 'dashboard#test_email'
    # get '/dashboard/services', to: 'dashboard#services'
    resources :dashboards do
      collection do
        post :fullsearch
        get :test_email
        get :services
      end
    end
  end

  devise_for :users, controllers: {
    registrations: 'users/registrations',
    sessions: 'users/sessions',
    passwords: 'users/passwords',
  }

  resources :users do
    post :impersonate, on: :member
    post :stop_impersonating, on: :collection
    collection do
      get '/:id/check_email', action: 'check_email', as: 'check_email'
      get '/:id/add_message_setup_ability', action: 'add_message_setup_ability', as: 'add_message_setup_ability'
      get '/:id/add_insales_order_webhook', action: 'add_insales_order_webhook', as: 'add_insales_order_webhook'
      delete '/:id/images/:image_id', action: 'delete_image', as: 'delete_image'
    end
  end

end
