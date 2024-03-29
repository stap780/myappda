class Useraccount < ApplicationRecord

    validates_format_of :email, with: URI::MailTo::EMAIL_REGEXP



end
