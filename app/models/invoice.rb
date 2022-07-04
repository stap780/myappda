class Invoice < ApplicationRecord

  belongs_to :payplan # не  задействовано так как поменяли логику работы
  has_many :payments, :dependent => :destroy

  # before_create :update_invoices_status
  before_create :set_data_if_new_record
  after_update :create_payment_record_after_invoice_update
  after_update :set_service_valid_after_update_invoice
  before_destroy :update_service_before_destroy_invoice

  def payment_date
    current_subdomain = Apartment::Tenant.current
    user = User.find_by_subdomain(current_subdomain)
    payment = Payment.where(user_id: user.id, payplan_id: self.payplan.id, invoice_id: self.id).first
    data = payment.present? ? payment.paymentdate.in_time_zone.strftime("%d/%m/%Y %H:%M" ) : ''
    data
  end


private

  # def update_invoices_status # отключил так как убрали статус Отменён
  #   Invoice.where(status: "Не оплачен").update_all(status: "Отменён") if Invoice.all.present?
  # end

  def set_data_if_new_record
    self.sum = self.payplan.price if new_record?
    self.status = 'Не оплачен' if new_record? && self.status.nil?
  end

  def create_payment_record_after_invoice_update
    current_subdomain = Apartment::Tenant.current
    user = User.find_by_subdomain(current_subdomain)
    payment = Payment.where(user_id: user.id, payplan_id: self.payplan.id)
    self.payments.create(user_id: user.id, payplan_id: self.payplan.id, status: 'Не оплачен', paymenttype: self.paymenttype ) if !payment.present?
  end

  def update_service_before_destroy_invoice
    if self.status != "Отменён"
      if self.service_handle == "favorite"
        fs = FavoriteSetup.all.first
        favorite_free_payplan_id = Payplan.favorite_free_id
        fs.update_attributes(payplan_id: favorite_free_payplan_id, valid_until: nil) if fs
      end
      if self.service_handle == "restock"
        rs = RestockSetup.all.first
        restock_free_payplan_id = Payplan.restock_free_id
        rs.update_attributes(payplan_id: restock_free_payplan_id, valid_until: nil) if rs
      end
    end
  end

  def set_service_valid_after_update_invoice
    if !new_record? && saved_change_to_status?
      service_handle = self.service_handle
      payplan = Payplan.find_by_id(self.payplan_id)
      add_period = payplan.period
      if payplan.price != 0 && self.status == 'Оплачен'
        if service_handle == "favorite"
          fs = FavoriteSetup.all.first
          old_valid_until = fs.valid_until.nil? ? Date.today : fs.valid_until
          new_valid_until = old_valid_until + "#{add_period}".to_i.months
          fs.update_attributes(valid_until: new_valid_until)
        end
        if service_handle == "restock"
          rs = RestockSetup.all.first
          old_valid_until = rs.valid_until.nil? ? Date.today : rs.valid_until
          new_valid_until = old_valid_until + "#{add_period}".to_i.months
          rs.update_attributes(valid_until: new_valid_until)
        end
      end
    end
  end


end
