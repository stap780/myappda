class Services::EventAction

    def self.do_action(user, event, mycase)

        action = event.event_actions.first
        channel = action.channel
        operation = action.operation
        pause = action.pause
        pause_time = action.pause_time
        timetable = action.timetable
        timetable_time = action.timetable_time
        receiver = mycase.client.email if action.template.receiver == 'client'
        receiver = user.email if action.template.receiver == 'manager'

        subject_template = Liquid::Template.parse(action.template.subject)
        content_template = Liquid::Template.parse(action.template.content)

        user_drop = Services::Drop::User.new(user)
        if mycase.casetype != 'order'
            case_drop = Services::Drop::Case.new(mycase)
            client_drop = Services::Drop::Client.new(mycase.client)
        end
        if mycase.casetype == 'order'
            insint = user.insints.first
            service = Services::InsalesApi.new(insint)
            order = service.order(mycase.insales_order_id)
            client = service.client(order.client.id)
            case_drop = Services::Drop::InsalesOrder.new(order)
            client_drop = Services::Drop::InsalesClient.new(client)
        end

        subject = subject_template.render('case' => case_drop, 'client' => client_drop)
        content = content_template.render('case' => case_drop, 'client' => client_drop, 'user' => user_drop)

        email_data = {
            user: user, 
            subject: subject,
            content: content,
            receiver: receiver
        }

        wait = pause == true && pause_time.present? ? pause_time : 1
        if channel == 'email'
            EventMailer.with(email_data).send_action_email.deliver_later(wait: wait.to_i.minutes)
        end
        if channel == 'insales_api' && operation == 'cancel_order'
            CancelOrderJob.set(wait: wait.to_i.minutes).perform_later(mycase.insales_order_id, operation, insint)
        end
        if channel == 'insales_api' && operation == 'preorder_order'
            #PreorderOrderJob.set(wait: wait.to_i.minutes).perform_later(mycase.insales_order_id, operation, insint)
        end


    end

end