class MessageSetup < ApplicationRecord
    belongs_to :payplan

    validates :title, presence: true
    validates :handle, uniqueness: true
    before_save :normalize_data_white_space
    before_save :set_valid_until_for_free_payplan, on: [:create, :update]
    after_commit :create_invoice, on: [:create, :update]
    after_commit :send_file_to_store_if_new, on: [:create]

    HANDLE = "message"
    TITLE = "Сообщения и тригеры по заказам"
    DESCRIPTION = "уведомлений клиентов и менеджеров интернет-магазина при смене статусов заказов с помощью InsalesApi, SMS, Email сообщений"
    
          
    def self.check_ability #проверяем тариф и определяем как будет обрабатываться запрос
      payplan_ability = false
          
      ms = MessageSetup.all.first
      if ms
        ms_status = ms.status == true ? true : false
        puts "ms_status => "+ms_status.to_s

        valid_until_ability = ms.valid_until.present? &&  Date.today <= ms.valid_until ? true : false

        puts "valid_until_ability => "+valid_until_ability.to_s

        check_work = ms_status == true && valid_until_ability == true ? true : false
      end
    end
    
    def self.check_valid_until #проверяем срок и переводим на бесплатный тариф
      ms = MessageSetup.all.first
      if !ms.nil? && ms.payplan_id != Payplan.message_free_id
        valid_until_data = ms.valid_until == nil ? Date.today-5.year : ms.valid_until
        puts "MessageSetup ID: #{ms.id.to_s} => check_valid_until: #{valid_until_data.to_s}"
        ms.update(payplan_id: Payplan.message_free_id, valid_until: nil) if Date.today > valid_until_data
      end
    end

    def have_free_payplan_invoice_and_no_valid?
        check_invoice = Invoice.where(payplan_id: Payplan.message_free_id).present? ? true : false
        check_date = Date.today > self.valid_until ? true : false
        check_invoice == true && check_date == true ? true : false
    end
  
  private
    
    def send_file_to_store_if_new
      user = User.find_by_subdomain(Apartment::Tenant.current)
      if user.insints.last.status
        service = Services::InsalesApi.new(user.insints.first)
        service.add_order_webhook
        # service.delete_order_webhook if self.status == false
      end
    end

    def set_valid_until_for_free_payplan
      self.valid_until = Date.today+14.days if self.payplan_id == Payplan.message_free_id && self.status  == true
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
          payment = invoice.get_payment.update(paymentdate: Date.today, status: "Оплачен")
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
    
    
    