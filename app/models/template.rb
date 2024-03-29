class Template < ApplicationRecord
  has_many :event_actions, dependent: :destroy
  has_many :events, through: :event_actions
  validates :title, presence: true
  validates :subject, presence: true
  validates :receiver, presence: true
  before_save :normalize_data_white_space

  def self.ransackable_attributes(auth_object = nil)
    Template.attribute_names
  end

  def validate_receiver_field

  end

  private

  def normalize_data_white_space
    attributes.each do |key, value|
      self[key] = value.squish if value.respond_to?(:squish)
    end
  end

end


