class EventActionService

    def initialize(user, event, mycase)
        @user = user
        @event = event
        @mycase = mycase
    end

    def do_action

        action = @event.event_actions.first
        channel = action.channel
        operation = action.operation
        pause = action.pause
        pause_time = action.pause_time
        timetable = action.timetable
        timetable_time = action.timetable_time
        receiver = @mycase.client.email if action.template.receiver == 'client'
        receiver = action.template.receiver if action.template.receiver != 'client'
        insint = @user.insints.first
        wait = pause == true && pause_time.present? ? pause_time : 1

        subject_template = Liquid::Template.parse(action.template.subject)
        content_template = Liquid::Template.parse(action.template.content)

        user_drop = Drops::User.new(@user)

        if channel == 'email'
            if @mycase.casetype != 'order'
                case_drop = Drops::Case.new(mycase)
                client_drop = Drops::Client.new(mycase.client)
            end
            if @mycase.casetype == 'order'
                check_trigger
                service = ApiInsales.new(insint)
                order = service.order(@mycase.insales_order_id)
                client = service.client(order.client.id)
                case_drop = Drops::InsalesOrder.new(order)
                client_drop = Drops::InsalesClient.new(client)
            end

            subject = subject_template.render('case' => case_drop, 'client' => client_drop)
            content = content_template.render('case' => case_drop, 'client' => client_drop, 'user' => user_drop)

            email_data = {
                            user: @user, 
                            subject: subject,
                            content: content,
                            receiver: receiver
                        }
            if @mycase.casetype != 'abandoned_cart' && check_trigger == true
                EventMailer.with(email_data).send_action_email.deliver_later(wait: wait.to_i.minutes)
            end
            if @mycase.casetype == 'abandoned_cart'
                AbandonedJob.set(wait: wait.to_i.minutes).perform_later(@mycase.id, insint, email_data)
            end
        end

        if channel == 'insales_api' && operation == 'cancel_order'            
            CancelOrderJob.set(wait: wait.to_i.minutes).perform_later(@mycase.insales_order_id, operation, insint)
        end

        if channel == 'insales_api' && operation == 'change_order_status_to_new'            
            ChangeOrderStatusToNewJob.set(wait: wait.to_i.minutes).perform_later(@mycase.insales_order_id, operation, insint)
        end

        if channel == 'insales_api' && operation == 'preorder_order'
            PreorderJob.set(wait: wait.to_i.minutes).perform_later(@mycase.id, operation, insint)
        end

    end

    private 

    def check_trigger
        check = false
        if @mycase.insales_custom_status_title == @event.custom_status &&
            @mycase.insales_financial_status == @event.financial_status

            check = true

        end
        check
    end
end

# test
# PreorderJob.set(wait: 1.minutes).perform_later(267,"preorder_order",User.find(407).insints.first)
