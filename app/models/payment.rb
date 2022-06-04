class Payment < ApplicationRecord
  belongs_to :user
  belongs_to :invoice
  belongs_to :payplan

  #validates :subdomain, presence: true #не понял зачем это

  before_create :add_subdomain #не понял зачем это
  after_update :update_invoice_after_update_payment

  Status = ['Не оплачен','Оплачен']
  Paymenttype = [['Счёт для юр лиц', 'invoice'],['Кредитные карты', 'creditcard'], ['Paypal', 'paypal']]

  private

  def add_subdomain
    self.subdomain = user.subdomain
  end

  def update_invoice_after_update_payment
    if !new_record? && saved_change_to_status?
      tenant = self.user.subdomain
      Apartment::Tenant.switch(tenant) do
        invoice = Invoice.find_by_id(self.invoice_id)
        invoice.update(status: 'Оплачен') if self.status == 'Оплачен'
      end
    end
  end

end
