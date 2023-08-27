class Payment < ApplicationRecord
  belongs_to :user
  belongs_to :payplan

  # validates :paymentdate, presence: true

  before_create :add_subdomain #не помню зачем это
  after_commit :update_invoice_after_update_payment, on: [:update]

  Status = ['Не оплачен','Оплачен']
  Paymenttype = [['Счёт для юр лиц', 'invoice'],['Кредитные карты', 'creditcard'], ['Paypal', 'paypal']]


  def destroy_invoice
    tenant = self.user.subdomain
    Apartment::Tenant.switch(tenant) do
      invoice = Invoice.find_by_id(self.invoice_id)
      invoice.destroy
    end
  end

  private

  def add_subdomain
    self.subdomain = user.subdomain
  end

  def update_invoice_after_update_payment
    if !new_record? && saved_change_to_status?
      tenant = self.user.subdomain
      Apartment::Tenant.switch(tenant) do
        invoice = Invoice.find_by_id(self.invoice_id)
        invoice.update!(status: 'Оплачен') if self.status == 'Оплачен'
      end
    end
  end

end
