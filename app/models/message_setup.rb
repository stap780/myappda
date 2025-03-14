#  MessageSetup < ApplicationRecord
class MessageSetup < ApplicationRecord
  belongs_to :payplan, optional: true # NOTICE это убирает проверку presence: true , которая стоит по дефолту
  include ActionView::RecordIdentifier

  validates :valid_until, presence: true

  HANDLE = 'message'
  TITLE = 'Тригеры (Сообщения и api по заказам)'
  DESCRIPTION = 'уведомлений клиентов и менеджеров интернет-магазина при смене статусов заказов с помощью InsalesApi, SMS, Email сообщений, а так же Брошенная корзина, Предзаказ, Сообщить о поступлении'

  def self.ransackable_attributes(auth_object = nil)
    MessageSetup.attribute_names
  end

  def self.check_ability
    MessageSetup.first.status
  end

  # NOTICE this methode we use for set service status at 23-35 by MessageServiceScheduler
  def self.set_service_status
    ms = MessageSetup.first
    ms.status = ms.present? && ms&.valid_until ? Date.today <= ms&.valid_until : false
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
      end
    end
  end

  def add_extra_ability
    update!(valid_until: Date.today + 4.week) if valid_until.present? && valid_until <= Date.today
  end

end
