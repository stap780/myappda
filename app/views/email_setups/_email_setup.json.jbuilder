json.extract! email_setup, :id, :address, :port, :domain, :authentication, :user_name, :user_password, :tls, :created_at, :updated_at
json.url email_setup_url(email_setup, format: :json)
