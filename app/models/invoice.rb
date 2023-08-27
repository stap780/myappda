class Invoice < ApplicationRecord

  belongs_to :payplan
  has_many :payments, :dependent => :destroy

  before_create :set_data_if_new_record
  after_create :create_payment
  # after_update :set_service_valid_after_update_invoice
  # before_destroy :update_service_before_destroy_invoice

  def get_user
    current_subdomain = Apartment::Tenant.current
    user = User.find_by_subdomain(current_subdomain)
  end

  def get_payment
    check_payment = Payment.where(user_id: self.get_user.id, payplan_id: self.payplan.id, invoice_id: self.id)
    payment = check_payment.present? ? check_payment.first : nil
  end
  
  def payment_date
    self.get_payment.present? ? self.get_payment.paymentdate.in_time_zone.strftime("%d/%m/%Y %H:%M" ) : ''
  end

  def set_service_valid_after_update_invoice
    if !new_record? && saved_change_to_status?
      # service_handle = self.service_handle
      # payplan = Payplan.find_by_id(self.payplan_id)
      payplan = self.payplan
      service_handle = payplan.service_handle
      add_period = payplan.period
      if payplan.price.to_i != 0 && self.status == 'Оплачен'
        if service_handle == "favorite"
          fs = FavoriteSetup.first
          old_valid_until = fs.valid_until.nil? || !fs.valid_until.nil? && fs.valid_until < Date.today ? Date.today : fs.valid_until
          new_valid_until = old_valid_until + "#{add_period}".to_i.months
          fs.update!(valid_until: new_valid_until)
        end
        if service_handle == "message"
          ms = MessageSetup.first
          old_valid_until = ms.valid_until.nil? || !ms.valid_until.nil? && ms.valid_until < Date.today ? Date.today : ms.valid_until
          new_valid_until = old_valid_until + "#{add_period}".to_i.months
          ms.update!(valid_until: new_valid_until)
        end
      end
    end
  end

private

  def set_data_if_new_record
    if new_record?
      self.sum = self.payplan.price 
      self.status = 'Не оплачен' if self.status.nil?
    end
  end

  def create_payment
    if !self.get_payment.present?
      self.payments.create!( user_id: self.get_user.id, payplan_id: self.payplan.id, status: 'Не оплачен', paymenttype: self.paymenttype )
    end
  end

end
