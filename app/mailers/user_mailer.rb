class UserMailer < ApplicationMailer

  default from: 'info@k-comment.ru'

    def test_welcome_email
      @user = User.first#params[:user]
      @url  = 'http://example.com/login'
      # mail(to: @user.email, subject: 'Welcome to My Awesome Site')
      mail(to: "panaet80@gmail.com", subject: 'Welcome to My Awesome Site')
    end

end
