    class EventOrderStatusChange < ApplicationRecord
      belongs_to :event
      belongs_to :order_status_change

      validates :event_id, presence: true
      validates :order_status_change_id, presence: true
      before_save :normalize_data_white_space
    
                
    def normalize_data_white_space
      self.attributes.each do |key, value|
        self[key] = value.squish if value.respond_to?("squish")
      end
    end
    
    end
    
    
    