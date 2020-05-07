class Users::RegistrationsController < Devise::RegistrationsController
  before_action :configure_sign_up_params, only: [:create]
  before_action :configure_account_update_params, only: [:update]
  after_action :set_user_valid_date, only: [:create]
  after_action :send_admin_email, only: [:create]



  # # # GET /resource/sign_up
  # def new
  #   super
  # end

  # # POST /resource
  def create
    super
  end

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

  def set_user_valid_date
    if current_user.present?
      current_user.valid_from = current_user.created_at
      current_user.valid_until = current_user.created_at + 7.days
      current_user.save
    end
  end

  def send_admin_email
    if current_user.present?
      UserMailer.test_welcome_email(current_user.email).deliver_now
    end
  end
end
