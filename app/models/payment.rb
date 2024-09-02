class Payment < ApplicationRecord
  belongs_to :user
  belongs_to :payplan

  # validates :paymentdate, presence: true

  before_create :add_subdomain #не помню зачем это
  after_commit :update_invoice_after_payment, on: [:update]

  Status = ['Не оплачен','Оплачен']
  Paymenttype = [['Счёт для юр лиц', 'invoice'],['Кредитные карты', 'creditcard'], ['Paypal', 'paypal']]

  def self.ransackable_attributes(auth_object = nil)
    Payment.attribute_names
  end

  def self.ransackable_associations(auth_object = nil)
    ["payplan", "user"]
  end

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

  def update_invoice_after_payment
    if status == 'Оплачен' && !new_record? && saved_change_to_status?
      tenant = self.user.subdomain
      Apartment::Tenant.switch(tenant) do
        invoice = Invoice.find_by_id(self.invoice_id)
        invoice.update!(status: 'Оплачен')
        invoice.set_service_valid_after_payment
      end
    end
  end

end
