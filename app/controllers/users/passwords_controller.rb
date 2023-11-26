class Users::PasswordsController < Devise::PasswordsController
  prepend_before_action :validate_recaptchas, only: [:create]
  # GET /resource/password/new
  # def new
  #   super
  # end

  # POST /resource/password
  # def create
  #   super
  # end

  # GET /resource/password/edit?reset_password_token=abcdef
  # def edit
  #   super
  # end

  # PUT /resource/password
  # def update
  #   super
  # end

  # protected

  # def after_resetting_password_path_for(resource)
  #   super(resource)
  # end

  # The path used after sending reset password instructions
  # def after_sending_reset_password_instructions_path_for(resource_name)
  #   super(resource_name)
  # end

  protected

  def validate_recaptchas
    v3_verify = verify_recaptcha(action: 'password/reset', 
                                 minimum_score: 0.9, 
                                 secret_key: Rails.application.credentials.recaptcha_site_key)
    return if v3_verify

    self.resource = resource_class.new sign_in_params
    respond_with_navigational(resource) { render :new }
  end

end
