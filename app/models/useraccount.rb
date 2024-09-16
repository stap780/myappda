class Useraccount < ApplicationRecord
    validates :name, presence: true
    validates :email, presence: true
    validates_format_of :email, with: URI::MailTo::EMAIL_REGEXP

    after_create_commit { broadcast_prepend_to "useraccounts" }
    after_update_commit { broadcast_replace_to "useraccounts" }
    after_destroy_commit { broadcast_remove_to "useraccounts" }



end
