class RestockSetup < ApplicationRecord

  #####

  ### Этот раздел не работает, так как сменили принцип всего приложения
  ### Теперь у нас Триггеры и всё настраивается в разделе Message

  #####
  belongs_to :payplan

  validates :title, presence: true
  validates :handle, uniqueness: true
  after_initialize :set_default_for_new_record
  # after_commit :send_file_to_store
  after_commit :create_invoice, on: [:create, :update]
  # before_validation :set_status_false_if_new_record
  HANDLE = "restock"
  TITLE = "Сообщить о поступлении"
  DESCRIPTION = "Извещение клиентов магазина о поступлении товаров в продажу"

  def self.check_ability #проверяем тариф и определяем как будет обрабатываться запрос
    payplan_ability = false

    client_restock = Client.restock_count

    rs = RestockSetup.all.first
    rs_status = rs.status == true ? true : false
    payplan = Payplan.find_by_id(rs.payplan_id)

    client_limit = 300 if payplan.handle == "restock_free"
    client_limit = 1000 if payplan.handle == "restock_300"
    client_limit = 10000 if payplan.handle == "restock_1000"

    payplan_ability = true if client_restock <= client_limit

    check_work = rs_status == true && payplan_ability == true ? true : false
    check_work
  end

  def self.check_valid_until #проверяем срок и переводим на бесплатный тариф
    fs = RestockSetup.all.first
    Date.today > fs.valid_until ? fs.update(payplan_id: Payplan.restock_free_id, valid_until: nil) : nil
  end


  private

    def set_default_for_new_record
      if new_record?
        self.payplan_id = Payplan.restock_free_id
        self.valid_until = nil
      end
    end

    def send_file_to_store #доделать отправку файлов в магазин
      # if !new_record? && saved_change_to_status?
      #   user = User.find_by_subdomain(Apartment::Tenant.current)
      #   insint = user.insints.first
      #   service = Services::restock.new(insint.id)
      #   service.load_script if self.status == true
      #   service.delete_ins_file if self.status == false
      # end
    end

    def create_invoice
      invoice_data = {
        payplan_id: self.payplan.id, 
        payertype: "fiz", 
        paymenttype: "creditcard", 
        service_handle: self.payplan.service_handle 
      }
      if self.status
        if self.payplan_id == Payplan.restock_free_id
          invoice = Invoice.create(invoice_data.merge!(status: "Оплачен"))
          payment = invoice.get_payment.update(paymentdate: Date.today, status: "Оплачен")
        else
          invoice = Invoice.create(invoice_data)
        end
      end
    end
  
  # def set_status_false_if_new_record
  #   self.status = false if new_record?
  # end


end
