# class EventMailer
class EventMailer < ApplicationMailer

  before_action do
    @user = params[:user]
    @subject = params[:subject]
    @content = params[:content]
    @receiver = params[:receiver]
  end
  before_action :set_from_email
  after_action :set_delivery_options

  def send_action_email
    @user_email = @user.email
    @user_email_from = set_from_email
    mail( to: @receiver, from: @user_email_from, subject: @subject )
  end

  private

  def set_from_email
    return 'info@myappda.ru' unless @user&.has_smtp_settings?

    email_address_with_name(@user.smtp_settings[:user_name], @user.name.to_s)
  end

  def set_delivery_options
    if @user&.has_smtp_settings?
      mail.delivery_method.settings.merge!(@user.smtp_settings)
    else
      mail.delivery_method.settings.merge!(User.default_smtp_settings)
    end
  end

end
