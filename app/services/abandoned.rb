# Abandoned < ApplicationService
class Abandoned < ApplicationService

  def initialize(mycase_id, tenant, email_data, last)
    @mycase_id = mycase_id
    @tenant = tenant
    @email_data = email_data
    @last = last # last is a boolean
  end

  def call
    # NOTICE 
    # if we have order that equal to abandoned
    # we set status finish to mycase
    #
    # if we don't have order that equal to abandoned
    # we send email
    # NOTICE end
    if order_present?
      set_status_finish
    else
      send_email
      set_status_finish if @last
    end
  end

  private

  def order_present?
    # NOTICE we check if abandoned equal to order
    check = []
    Apartment::Tenant.switch(@tenant) do
      mycase = Mycase.find(@mycase_id)
      mycase.update(status: 'take') if mycase.status == 'new'
      mycase_lines = mycase.lines.pluck(:variant_id)
      orders = Mycase.where(client_id: mycase.client_id, casetype: 'order').where('created_at > ?', mycase.created_at)
      orders.each do |order|
        order_lines = order.lines.pluck(:variant_id)
        check.push(order_lines.sort == mycase_lines.sort)
      end
    end
    check.uniq.include?(true)
  end

  def send_email
    EventMailer.with(@email_data).send_action_email.deliver_now
  end

  def set_status_finish
    Apartment::Tenant.switch(@tenant) do
      Mycase.find(@mycase_id).update(status: 'finish')
    end
  end

end
