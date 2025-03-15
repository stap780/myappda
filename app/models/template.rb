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


  private

  def normalize_whitespace
    attributes.each do |key, value|
      # puts "key: #{key}, value: #{value}"
      excluded_keys = %w[content]
      next if excluded_keys.include?(key)

      self[key] = value.squish if value.respond_to?(:squish)
    end
  end

end


