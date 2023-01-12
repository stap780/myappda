class Template < ApplicationRecord
  has_many :event_actions
  # before_save :normalize_data_white_space
  validates :title, presence: true
  validates :subject, presence: true
  
  RECEIVER = [['client','Клиент'],['manager','Менеджер']]

            
  # def normalize_data_white_space
  #   self.attributes.each do |key, value|
  #     self[key] = value.squish if value.respond_to?("squish")
  #   end
  # end

end
    
    
    