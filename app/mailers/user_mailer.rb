class UserMailer < ApplicationMailer
  before_action { @user = params[:user] }
  before_action :set_from_email
  after_action :set_delivery_options

    def test_welcome_email
      @user_email = @user.email
      @user_email_from = set_from_email
      mail(to: "panaet80@gmail.com, info@two-g.ru",
          reply_to: @user_email,
          from:  @user_email_from,
          subject: 'Новая регистрация в приложении K-Comment')
    end

    def service_end_email
      @user_email = @user.email
      @user_email_from = set_from_email
      @url  = 'https://k-comment.ru/users/sign_in'
      mail(
        to: @user_email,
        from:  @user_email_from,
        subject: 'Заканчивается срок оплаты сервиса')
    end

    def favorite_setup_service_email
      @user_email =@user.email
      @user_email_from = set_from_email
      @client_count = @user.client_count
      @url  = 'https://k-comment.ru/users/sign_in'
      mail(
        to: @user_email,
        from:  @user_email_from,
        subject: 'Сервис Избранные товары не работает для ваших клиентов')
    end

    private

    def set_from_email
      @user && @user.has_smtp_settings? ? @user.smtp_settings[:user_name] : 'info@k-comment.ru'
    end

    def set_delivery_options
      if @user && @user.has_smtp_settings?
        mail.delivery_method.settings.merge!(@user.smtp_settings)
      end
    end

end
