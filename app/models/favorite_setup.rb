class FavoriteSetup < ApplicationRecord

belongs_to :payplan

validates :title, presence: true
validates :handle, uniqueness: true
after_initialize :set_default_for_new_record
# after_commit :send_file_to_store
after_commit :create_invoice, on: [:create, :update]
HANDLE = "favorite"
TITLE = "Избранное"
DESCRIPTION = "Добавление и удаление товаров в/из избранного на любом устройстве для зарегистрированных клиентов магазина"


def self.check_ability #проверяем тариф и определяем как будет обрабатываться запрос
  payplan_ability = false

  client_favorite_count = Client.uniq_favorites_count #Client.where.not(izb_productid: [nil, '']).count

  fs = FavoriteSetup.all.first
  fs_status = fs.status == true ? true : false
  payplan = Payplan.find_by_id(fs.payplan_id)

  client_limit = 300 if payplan.handle == "favorite_free"
  client_limit = 1000 if payplan.handle == "favorite_300"
  client_limit = 10000 if payplan.handle == "favorite_1000"

  payplan_ability = true if client_favorite_count <= client_limit

  check_work = fs_status == true && payplan_ability == true ? true : false
end

def self.check_valid_until #проверяем срок и переводим на бесплатный тариф
  fs = FavoriteSetup.all.first
  if !fs.nil? && fs.payplan_id != Payplan.favorite_free_id
    valid_until_data = fs.valid_until == nil ? Date.today-5.year : fs.valid_until
    puts "FavoriteSetup ID: #{fs.id.to_s} => check_valid_until: #{valid_until_data.to_s}"
    Date.today > valid_until_data ? fs.update(payplan_id: Payplan.favorite_free_id, valid_until: nil) : nil
  end
end

private

def set_default_for_new_record
  if new_record?
    self.payplan_id = Payplan.favorite_free_id
    self.valid_until = nil
  end
end

# def send_file_to_store
#   if !new_record? && saved_change_to_status?
#     user = User.find_by_subdomain(Apartment::Tenant.current)
#     insint = user.insints.first
#     service = FavoriteService.new(insint)
#     service.load_script if self.status == true
#     service.delete_ins_file if self.status == false
#   end
# end

def create_invoice
  invoice_data = {
    payplan_id: self.payplan.id, 
    payertype: "fiz", 
    paymenttype: "creditcard", 
    service_handle: self.payplan.service_handle 
  }
  if self.status
    if self.payplan_id == Payplan.favorite_free_id
      invoice = Invoice.create(invoice_data.merge!(status: "Оплачен"))
      payment = invoice.get_payment.update(paymentdate: Date.today, status: "Оплачен")
    else
      invoice = Invoice.create(invoice_data)
    end
  end
end


end
