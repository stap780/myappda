class MessageSetup < ApplicationRecord
  belongs_to :payplan, optional: true # это убирает проверку presence: true , которая стоит по дефолту
  include ActionView::RecordIdentifier
  # validates :title, presence: true
  # validates :handle, uniqueness: true
  before_save :normalize_data_white_space
  # before_save :set_valid_until_for_free_payplan_new, if: [:create] #убираем тарифы из сервисов и разрываем логическую связь с ними
  # after_create :create_order_webhook_and_xml
  # after_commit :create_invoice, on: [:create, :update]
  # before_save :set_free_valid, if: :new_record?

  after_create_commit do
    broadcast_update_to :message_setups, target: dom_id(User.current, dom_id(MessageSetup.new)), html: ''
    broadcast_append_to :message_setups,  target: dom_id(User.current, :message_setups), 
                                          partial: 'message_setups/message_setup', 
                                          locals: { message_setup: self, current_user: User.current}
  end
  after_update_commit do
    broadcast_replace_to :message_setups, target: dom_id(User.current, dom_id(self)), 
                                          partial: 'message_setups/message_setup', 
                                          locals: { message_setup: self, current_user: User.current}
  end


  HANDLE = "message"
  TITLE = "Тригеры (Сообщения и api по заказам)"
  DESCRIPTION = "уведомлений клиентов и менеджеров интернет-магазина при смене статусов заказов с помощью InsalesApi, SMS, Email сообщений, а так же Брошенная корзина, Предзаказ, Сообщить о поступлении"

  def self.ransackable_attributes(auth_object = nil)
    MessageSetup.attribute_names
  end


  def self.check_ability
    ms = MessageSetup.first
    if ms
      ms_status = ms.status == true ? true : false

      valid_until_ability = ms.valid_until.present? &&  Date.today <= ms.valid_until ? true : false

      puts "MessageSetup valid_until_ability => "+valid_until_ability.to_s

      check_work = ms_status == true && valid_until_ability == true ? true : false
    end
  end

  def api_create_restock_xml
    user = User.find_by_subdomain(Apartment::Tenant.current)
    service = user.insints.first.present? ? ApiInsales.new(user.insints.first) : nil
    if user.insints.last.status && service
      xml = service.create_xml
      if xml
        self.product_xml = xml.url
        self.save
      # else
      #   self.product_xml = 'обратитесь в поддержку чтобы они прописали ссылку на файл с товарами'
      #   self.save
      end
    end
  end

  def add_extra_ability
    self.update!(valid_until: Date.today + 4.week) if self.valid_until.present? && self.valid_until <= Date.today
  end


  private

  # def set_valid_until_for_free_payplan_new
  #   self.valid_until = Date.today+14.days if new_record? if self.payplan_id == Payplan.message_free_id && self.status  == true
  # end

  # def set_free_valid
  #   self.valid_until = Date.today + 4.week
  # end

  # def create_invoice
  #   invoice_data = {
  #     payplan_id: self.payplan.id, 
  #     payertype: "fiz", 
  #     paymenttype: "creditcard", 
  #     service_handle: self.payplan.service_handle 
  #   }
  #   if self.status
  #     if self.payplan_id == Payplan.message_free_id
  #       invoice = Invoice.create(invoice_data.merge!(status: "Оплачен"))
  #       payment = invoice.get_payment.update!(paymentdate: Date.today, status: "Оплачен")
  #     else
  #       not_have_invoice = Invoice.where(invoice_data.merge!(status: "Не оплачен"))
  #       invoice = Invoice.create(invoice_data) if not_have_invoice
  #     end
  #   end
  # end
                  
  def normalize_data_white_space
    self.attributes.each do |key, value|
      self[key] = value.squish if value.respond_to?("squish")
    end
  end


end