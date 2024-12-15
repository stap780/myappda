class Users::SessionsController < Devise::SessionsController
  ## prepend_before_action :validate_recaptchas, only: [:create] # для версии 3
  # prepend_before_action :check_captcha, only: [:create] #if !Rails.env.development?
  before_action :configure_sign_in_params, only: [:create]
  before_action :redirect_to_app_url, except: :destroy

  # GET /resource/sign_in
  # def new
  #   super
  # end

  def create 
    ActiveRecord::Base.transaction do
      @user = User.find_by_email(params['user']['email'])
      if @user.present?
        Apartment::Tenant.switch(@user.subdomain) do
          sign_in(:user, @user)
          redirect_to after_sign_in_path_for(@user), allow_other_host: true
        end
      else
        # render :action => 'new'
        # redirect_to root_url(subdomain: ''), allow_other_host: true
        redirect_to new_user_url
      end
    end
  end

  # DELETE /resource/sign_out
  def destroy
    sign_out(current_user)
    redirect_to after_sign_out_path_for(current_user), allow_other_host: true
  end

  protected

  # If you have extra params to permit, append them to the sanitizer.
  def configure_sign_in_params
    devise_parameter_sanitizer.permit(:sign_in, keys: [:attribute])
  end

  def check_sign_in_user; end

  private


  def validate_recaptchas #оставил как пример для  v3 - но не сработало
    v3_verify = verify_recaptcha(action: 'login', 
                                 minimum_score: 0.5, 
                                 secret_key: Rails.application.credentials.recaptcha_secret_key_v3)
    return if v3_verify

    self.resource = resource_class.new sign_in_params
    respond_with_navigational(resource) { render :new }
  end
  
  
  def check_captcha
    return if verify_recaptcha

    self.resource = resource_class.new sign_in_params

    respond_with_navigational(resource) do
      flash.discard(:recaptcha_error) # We need to discard flash to avoid showing it on the next page reload
      render :new
    end
  end

end
