# UserMailer
class UserMailer < ApplicationMailer
  before_action do
    @user = params[:user]
    @subject = params[:subject]
  end
  before_action :set_from_email
  after_action :set_delivery_options

  def test_welcome_email
    @user_email = @user.email
    @user_email_from = set_from_email
    mail(
      to: 'info@myappda.ru',
      reply_to: @user_email,
      from:  @user_email_from,
      subject: 'Новая регистрация в приложении myappda'
    )
  end

  def service_end_email
    @user_email = @user.email
    @user_email_from = set_from_email
    @url  = 'https://myappda.ru/users/sign_in'
    mail(
      to: @user_email,
      from:  @user_email_from,
      subject:  @subject
    )
  end

  def favorite_setup_service_email
    @user_email = @user.email
    @user_email_from = set_from_email
    @client_count = @user.client_count
    @url  = 'https://myappda.ru/users/sign_in'
    mail(
      to: @user_email,
      from:  @user_email_from,
      subject: 'Сервис Избранные товары не работает для ваших клиентов'
    )
  end

  def insales_client_api_import
    @user_email =@user.email
    @user_email_from = set_from_email
    @url  = 'https://myappda.ru/users/sign_in'
    mail(
      to: @user_email,
      from:  @user_email_from,
      subject: 'Клиенты импортировались в ваш магазин'
    )
  end

  private

  def set_from_email
    @user&.has_smtp_settings? ? @user.smtp_settings[:user_name] : 'info@myappda.ru'
  end

  def set_delivery_options
    if @user&.has_smtp_settings?
      mail.delivery_method.settings.merge!(@user.smtp_settings)
    else
      mail.delivery_method.settings.merge!(User.default_smtp_settings)
    end
  end

end
