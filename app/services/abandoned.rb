# Abandoned
class Abandoned < ApplicationService

  def initialize(mycase_id, tenant, email_data)
    @mycase_id = mycase_id
    @tenant = tenant
    @email_data = email_data
    @check = []
  end

  def call
    # if we have order that equal to abandoned
    # we set status finish to mycase
    #
    # if we don't have order that equal to abandoned
    # we send email and set status finish to mycase
    send_email if check_ability
    set_status_finish
  end

  private

  def check_ability
    # we check if abandoned equal to order
    Apartment::Tenant.switch(@tenant) do
      mycase = Mycase.find(@mycase_id)
      lines = mycase.lines.pluck(:variant_id)
      orders = Mycase.where(client_id: mycase.client_id, casetype: 'order').where('created_at > ?', mycase.created_at)
      orders.each do |order|
        @check.push(order.lines.pluck(:variant_id).sort == lines.sort)
      end
    end
    @check.uniq.include?(true) ? false : true
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
