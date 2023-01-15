class Template < ApplicationRecord
  has_many :event_actions, dependent: :destroy
  has_many :events, through: :event_actions
  validates :title, presence: true
  validates :subject, presence: true
  

            

end
    
    
    