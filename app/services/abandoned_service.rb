class AbandonedService

    def initialize(mycase_id, insint, email_data)
        @mycase_id = mycase_id
        @insint = insint
        @tenant = @insint.user.subdomain
        @email_data = email_data
    end

    def check_ability
        Apartment::Tenant.switch(@tenant) do
            mycase = Case.find(@mycase_id)
            lines = mycase.lines.pluck(:variant_id)
            check = []
            orders = Case.where(client_id: mycase.client_id, casetype: 'order').where('created_at > ?', mycase.created_at)
            orders.each do |order|
                check.push(order.lines.pluck(:variant_id).sort == lines.sort)
            end
            check.uniq.include?(true) ? false : true
        end
    end

    def do_action
        EventMailer.with(@email_data).send_action_email.deliver_now
    end
    
end