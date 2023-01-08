#  encoding : utf-8
namespace :liquid do
    desc "liquid template"
  
    task check_work: :environment do
        user = User.find 67
        service = Services::InsalesApi.new(user.insints.first)
        Apartment::Tenant.switch!(user.subdomain)
        order_status_change = OrderStatusChange.last
        order = service.order(order_status_change.insales_order_id)

        template = Liquid::Template.parse("hi order {{order.number}} and payment title - {{order.payment_title}}")
        order_drop = InsalesOrderDrop.new(order)

        # template.render('order' => {'number' => order.number})       

        t = template.render('order' => order_drop)
        puts "t => "+t.to_s
    end

    task do_event_action: :environment do
        user = User.find 67
        Apartment::Tenant.switch!(user.subdomain)
        osc = OrderStatusChange.last
        
        if osc.events.present?
            osc.events.each do |event|
            action = event.event_actions.first
            pause = action.pause
            pause_time = action.pause_time
            timetable = action.timetable
            receiver = osc.client.email if action.template.receiver == 'client'
            receiver = user.email if action.template.receiver == 'manager'
            
            service = Services::InsalesApi.new(user.insints.first)
            order = service.order(osc.insales_order_id)
    
            subject_template = Liquid::Template.parse(action.template.subject)
            content_template = Liquid::Template.parse(action.template.content)
            order_drop = InsalesOrderDrop.new(order)
    
            # template.render('order' => {'number' => order.number})       
    
            # template.render('order' => order_drop)
            # liquid(action.template.subject, context => {'order' => order_drop} )
            subject = subject_template.render('order' => order_drop)
            content = content_template.render('order' => order_drop)
            
            email_data = {
              user: user, 
              subject: subject, 
              content: content, 
              receiver: receiver
            }
            puts "email_data => "+email_data.to_s
            
            # if pause == true && pause_time.present?
            #   EventMailer.with(email_data).send_action_email.deliver_later(wait: "#{pause_time}".to_i.minutes)
            # end
            # if pause != true
            #   EventMailer.with(email_data).send_action_email.deliver_now
            # end
          end
        end
      end
    
  
  
  end
  