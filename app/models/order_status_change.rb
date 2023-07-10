class OrderStatusChange < ApplicationRecord
  belongs_to :client

  before_save :normalize_data_white_space
  # after_commit :do_event_action, on: [:create]
  


private

# перенёс в Case обработку всех событий
  # def do_event_action
  # end
  
  def normalize_data_white_space
    self.attributes.each do |key, value|
      self[key] = value.squish if value.respond_to?("squish")
    end
  end

end
    
    
    