class MessageSetup < ApplicationRecord
  belongs_to :payplan

  validates :title, presence: true
  validates :handle, uniqueness: true
  before_save :normalize_data_white_space
  before_save :set_valid_until_for_free_payplan_if_new, on: [:create]
  after_create :create_order_webhook_and_xml
  after_commit :create_invoice, on: [:create, :update]

  HANDLE = "message"
  TITLE = "Тригеры (Сообщения и api по заказам)"
  DESCRIPTION = "уведомлений клиентов и менеджеров интернет-магазина при смене статусов заказов с помощью InsalesApi, SMS, Email сообщений, а так же Брошенная корзина, Предзаказ, Сообщить о поступлении"

  def self.check_ability #проверяем тариф и определяем как будет обрабатываться запрос
    payplan_ability = false
        
    ms = MessageSetup.all.first
    if ms
      ms_status = ms.status == true ? true : false
      puts 'MessageSetup ms_status => '+ms_status.to_s

      valid_until_ability = ms.valid_until.present? &&  Date.today <= ms.valid_until ? true : false

      puts "MessageSetup valid_until_ability => "+valid_until_ability.to_s

      check_work = ms_status == true && valid_until_ability == true ? true : false
    end
  end


private
  
  def create_order_webhook_and_xml
    user = User.find_by_subdomain(Apartment::Tenant.current)
    if user.insints.last.status
      service = Services::InsalesApi.new(user.insints.first)
      service.add_order_webhook
      # service.delete_order_webhook if self.status == false
      xml = service.create_xml
      self.product_xml = xml.url
      self.save
    end
  end

  def set_valid_until_for_free_payplan_if_new
    if new_record?
      self.valid_until = Date.today+14.days if self.payplan_id == Payplan.message_free_id && self.status  == true
    end
  end
  
  def create_invoice
    invoice_data = {
      payplan_id: self.payplan.id, 
      payertype: "fiz", 
      paymenttype: "creditcard", 
      service_handle: self.payplan.service_handle 
    }
    if self.status
      if self.payplan_id == Payplan.message_free_id
        invoice = Invoice.create(invoice_data.merge!(status: "Оплачен"))
        payment = invoice.get_payment.update!(paymentdate: Date.today, status: "Оплачен")
      else
        invoice = Invoice.create(invoice_data)
      end
    end
  end
                  
  def normalize_data_white_space
    self.attributes.each do |key, value|
      self[key] = value.squish if value.respond_to?("squish")
    end
  end

  
end

