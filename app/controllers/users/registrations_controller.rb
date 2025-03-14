class Users::RegistrationsController < Devise::RegistrationsController
  # prepend_before_action :check_captcha, only: [:create]
  before_action :configure_sign_up_params, only: [:create]
  before_action :configure_account_update_params, only: [:update]
  after_action :set_user_valid_date_and_message_setup, only: [:create]
  # after_action :send_admin_email, only: [:create]


  # # # GET /resource/sign_up
  # def new
  #   super
  # end

  # POST /resource
  def create
    build_resource(sign_up_params)

    resource.save
    yield resource if block_given?
    if resource.persisted?
      if resource.active_for_authentication?
        set_flash_message! :notice, :signed_up
        sign_up(resource_name, resource)
        # respond_with resource, location: after_sign_up_path_for(resource)
        redirect_to after_sign_up_path_for(resource), allow_other_host: true
      else
        set_flash_message! :notice, :"signed_up_but_#{resource.inactive_message}"
        expire_data_after_sign_in!
        respond_with resource, location: after_inactive_sign_up_path_for(resource), allow_other_host: true
      end
    else
      clean_up_passwords resource
      set_minimum_password_length
      respond_with resource
    end
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

  protected

  # If you have extra params to permit, append them to the sanitizer.
  def configure_sign_up_params
    devise_parameter_sanitizer.permit(:sign_up, keys: [ :name, :subdomain ])
  end

  # If you have extra params to permit, append them to the sanitizer.
  def configure_account_update_params
    devise_parameter_sanitizer.permit(:account_update, keys: [:name, :email, :subdomain, :avatar, :phone, :admin ])
  end

  # # The path used after sign up.
  def after_sign_up_path_for(resource)
    mycases_url(subdomain: resource.subdomain)
  end

  # # The path used after sign up for inactive accounts.
  def after_inactive_sign_up_path_for(resource)
    root_url(subdomain: resource.subdomain)
  end

  def set_user_valid_date_and_message_setup
    if current_user.present?
      current_user.valid_from = current_user.created_at
      current_user.valid_until = Date.today+2.year
      current_user.save

      # NOTICE switch on service for new user
      current_user.message_service_start
    end
  end

  def send_admin_email
    if current_user.present?
      UserMailer.with(user: current_user).test_welcome_email.deliver_now
    end
  end

  private

  def check_captcha
    return if verify_recaptcha # verify_recaptcha(action: 'login') for v3

    self.resource = resource_class.new sign_in_params

    respond_with_navigational(resource) do
      flash.discard(:recaptcha_error) # We need to discard flash to avoid showing it on the next page reload
      render :new
    end
  end

end
