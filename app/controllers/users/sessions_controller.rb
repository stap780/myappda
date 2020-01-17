class Users::SessionsController < Devise::SessionsController
  before_action :configure_sign_in_params, only: [:create]
  before_action :redirect_to_app_url, except: :destroy

  # GET /resource/sign_in
  def new
    super
  end

  # POST /resource/sign_in
  def create
    super
      @user = User.find_by_email(params[:user][:email])
      if @user.present?
        if  @user.valid_until.nil? || @user.valid_until <= Date.today
          puts "время работы истекло - ставим плюс 1 день чтобы клиент сформировал себе счет на оплату"
          @user.update_attributes("valid_until" => Date.today)
          sign_in(:user, @user)
            if @user.subdomain == 'ketago' || @user.subdomain == 'twog'
              puts "админ вошёл - "+"#{@user.subdomain}"
              # redirect_to after_sign_in_path_for(@user)
            else
              # flash[:notice] = "#{ @user.email } время работы истекло."
              redirect_to invoice_path_for(@user), :notice => 'Оплаченный период истёк. Сервис не работает для Ваших клиентов. Пожалуйста оплатите сервис.'
            end
        else
          puts "мы здесь"
        end
      end
  end
  # def create
  #   super
  # end

  # DELETE /resource/sign_out
  def destroy
    super
  end

  # protected

  # If you have extra params to permit, append them to the sanitizer.
  def configure_sign_in_params
    devise_parameter_sanitizer.permit(:sign_in, keys: [:attribute])
  end

  def check_sign_in_user


  end
end
