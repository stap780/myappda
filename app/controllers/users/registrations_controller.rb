class Users::RegistrationsController < Devise::RegistrationsController
  before_action :configure_sign_up_params, only: [:new, :create]
  before_action :configure_account_update_params, only: [:update]
  before_action :redirect_to_app_url


  # # GET /resource/sign_up
  def new
    puts params[:shop].present?
    if params[:shop].present?
      save_subdomain = "insales"+params[:insales_id]
      email = save_subdomain+"@mail.ru"
      puts save_subdomain
      user = User.create(:name => params[:insales_id], :subdomain => save_subdomain, :password => save_subdomain, :password_confirmation => save_subdomain, :email => email)
      puts user.id
      if user.id.present?
        secret_key = 'my_test_secret_key'
        password = Digest::MD5.hexdigest(params[:token] + secret_key)
        Insint.create(:subdomen => params[:shop],  password: password, insalesid: params[:insales_id], :user_id => user.id)
      end
    render status :ok
    else
    super
    end
  end

  # # POST /resource
  # def create
  #   super
  # end

  # GET /resource/edit
  # def edit
  #   super
  # end

  # PUT /resource
  # def update
  #   super
  # end

  # DELETE /resource
  # def destroy
  #   super
  # end

  # GET /resource/cancel
  # Forces the session data which is usually expired after sign
  # in to be expired now. This is useful if the user wants to
  # cancel oauth signing in/up in the middle of the process,
  # removing all OAuth session data.
  # def cancel
  #   super
  # end

  # protected

  # If you have extra params to permit, append them to the sanitizer.
  def configure_sign_up_params
    devise_parameter_sanitizer.permit(:sign_up, keys: [ :name, :subdomain ])
  end

  # If you have extra params to permit, append them to the sanitizer.
  def configure_account_update_params
    devise_parameter_sanitizer.permit(:account_update, keys: [ :name, :subdomain ])
  end

  # The path used after sign up.
  def after_sign_up_path_for(resource)
    dashboard_index_url(subdomain: resource.subdomain)
  end

  # The path used after sign up for inactive accounts.
  def after_inactive_sign_up_path_for(resource)
    root_url(subdomain: resource.subdomain)
  end
end
