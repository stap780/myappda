class Users::SessionsController < Devise::SessionsController
  before_action :configure_sign_in_params, only: [:create]
  before_action :redirect_to_app_url, except: :destroy

  # GET /resource/sign_in
  def new
    super
  end

  # POST /resource/sign_in
  def create
      @user = User.find_by_email(params[:user][:email])
      if @user.present?
        if @user.valid_until <= Date.today
          puts "время работы истекло - ставим плюс 1 день чтобы клиент сформировал себе счет на оплату"
          @user.valid_until = Date.today
          @user.save
          sign_in(:user, @user)
          # flash[:notice] = "#{ @user.email } время работы истекло."
          redirect_to invoice_path_for(@user), :notice => 'Оплаченный период истёк. Сервис не работает для Ваших клиентов. Пожалуйста оплатите сервис.'
        else
          super
        end
      end
  end

  # DELETE /resource/sign_out
  def destroy
    super
  end

  # protected

  # If you have extra params to permit, append them to the sanitizer.
  def configure_sign_in_params
    devise_parameter_sanitizer.permit(:sign_in, keys: [:attribute])
  end
end
