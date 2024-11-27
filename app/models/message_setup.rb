class MessageSetup < ApplicationRecord
  belongs_to :payplan, optional: true # это убирает проверку presence: true , которая стоит по дефолту
  include ActionView::RecordIdentifier

  before_save :normalize_data_white_space
  before_save :set_valid_until_if_new_record
  validates :valid_until, presence: true

  # switch off callback and move turbo_stream to controller because it dificult debug
  # after_create_commit do
  #   broadcast_update_to :message_setups,  target: dom_id(User.current, dom_id(MessageSetup.new)),
  #                                         html: ''
  #   broadcast_append_to :message_setups,  target: dom_id(User.current, :message_setups),
  #                                         partial: 'message_setups/message_setup',
  #                                         locals: { message_setup: self, current_user: User.current}
  # end
  # after_update_commit do
  #   broadcast_replace_to :message_setups, target: dom_id(User.current, dom_id(self)),
  #                                         partial: 'message_setups/message_setup',
  #                                         locals: { message_setup: self, current_user: User.current}
  # end

  HANDLE = 'message'
  TITLE = 'Тригеры (Сообщения и api по заказам)'
  DESCRIPTION = 'уведомлений клиентов и менеджеров интернет-магазина при смене статусов заказов с помощью InsalesApi, SMS, Email сообщений, а так же Брошенная корзина, Предзаказ, Сообщить о поступлении'

  def self.ransackable_attributes(auth_object = nil)
    MessageSetup.attribute_names
  end

  def self.check_ability
    MessageSetup.first.status
  end

  def self.set_service_status
    ms = MessageSetup.first
    ms.status = (ms.valid_until.present? && Date.today <= ms.valid_until) ? true : false
    ms.save
  end

  def api_create_restock_xml
    user = User.find_by_subdomain(Apartment::Tenant.current)
    service = user.insints.first.present? ? ApiInsales.new(user.insints.first) : nil
    if user.insints.last.status && service
      xml = service.create_xml
      if xml
        self.product_xml = xml.url
        save
        # else
        #   self.product_xml = 'обратитесь в поддержку чтобы они прописали ссылку на файл с товарами'
        #   self.save
      end
    end
  end

  def add_extra_ability
    update!(valid_until: Date.today + 4.week) if valid_until.present? && valid_until <= Date.today
  end

  private

  def set_valid_until_if_new_record
    self.valid_until = Date.today + 30.days
  end

  def normalize_data_white_space
    attributes.each do |key, value|
      self[key] = value.squish if value.respond_to?(:squish)
    end
  end

end
