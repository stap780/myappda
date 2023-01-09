class EventAction < ApplicationRecord
  before_save :normalize_data_white_space

  belongs_to :event
  belongs_to :template

  validates :event_id, presence: true
  validates :template_id, presence: true

  CHANNEL = ['email']
            
  def normalize_data_white_space
    self.attributes.each do |key, value|
      self[key] = value.squish if value.respond_to?("squish")
    end
  end

end
    
    
    