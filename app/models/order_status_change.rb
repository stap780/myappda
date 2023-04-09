class OrderStatusChange < ApplicationRecord
  belongs_to :client

  before_save :normalize_data_white_space
  after_commit :do_event_action, on: [:create]
  


private

  def do_event_action
    events = Event.where(casetype: 'order', custom_status: self.insales_custom_status_title, financial_status: self.insales_financial_status)
    if events.present?
      puts "OrderStatusChange do_event_action"
      user = User.find_by_subdomain(Apartment::Tenant.current)
      events.each do |event|
        if event.casetype == 'order'
          action = event.event_actions.first
          channel = action.channel
          operation = action.operation
          pause = action.pause
          pause_time = action.pause_time
          timetable = action.timetable
          receiver = self.client.email if action.template.receiver == 'client'
          receiver = user.email if action.template.receiver == 'manager'
          insint = user.insints.first
          service = Services::InsalesApi.new(insint)
          order = service.order(self.insales_order_id)
          client = service.client(order.client.id)

          subject_template = Liquid::Template.parse(action.template.subject)
          content_template = Liquid::Template.parse(action.template.content)
          order_drop = Services::Drop::InsalesOrder.new(order)
          client_drop = Services::Drop::InsalesClient.new(client)


          subject = subject_template.render('order' => order_drop, 'client' => client_drop)
          content = content_template.render('order' => order_drop, 'client' => client_drop)
          
          email_data = {
            user: user, 
            subject: subject, 
            content: content, 
            receiver: receiver
          }
          # puts "email_data => "+email_data.to_s
          
          wait = pause == true && pause_time.present? ? pause_time : 1
          if channel == 'email'
            EventMailer.with(email_data).send_action_email.deliver_later(wait: wait.to_i.minutes)
          end
          if channel == 'insales_api'
            OrderJob.set(wait: wait.to_i.minutes).perform_later(self.insales_order_id, operation, insint)
          end
        end
      end
    end
  end
  
  def normalize_data_white_space
    self.attributes.each do |key, value|
      self[key] = value.squish if value.respond_to?("squish")
    end
  end

end
    
    
    