class EventAction < ApplicationRecord
  before_save :normalize_data_white_space

  belongs_to :event
  belongs_to :template

  validates :template_id, presence: true
  validates :channel, presence: true
  validates :operation, presence: true

  CHANNEL = [['Email','email'],['Insales API','insales_api']].freeze
  OPERATION = [['Отправить сообщение','send_email','email'],['Отменить заказ','cancel_order','insales_api'],['Создать заказ-предзаказ','preorder_order','insales_api']].freeze
  
  def normalize_data_white_space
    self.attributes.each do |key, value|
      self[key] = value.squish if value.respond_to?("squish")
    end
  end

end
