class OrderStatusChange < ApplicationRecord
  belongs_to :client
  has_many :event_order_status_changes
  has_many :events , through: :event_order_status_changes

  before_save :normalize_data_white_space
  after_create :add_event
  after_commit :do_event_action, on: [:create]




private

  def add_event
    events = Event.where(custom_status: self.insales_custom_status_title, financial_status: self.insales_financial_status)
    events.each do |event|
      event.event_order_status_changes.create(order_status_change_id: self.id)  if event.present?
    end
  end

  def do_event_action
    if self.events.present?
      user = User.find_by_subdomain(Apartment::Tenant.current)
      self.events.each do |event|
        action = event.event_actions.first
        pause = action.pause
        pause_time = action.pause_time
        timetable = action.timetable
        receiver = self.client.email if action.template.receiver == 'client'
        receiver = user.email if action.template.receiver == 'manager'
        
        service = Services::InsalesApi.new(user.insints.first)
        order = service.order(self.insales_order_id)
        client = service.client(order.client.id)

        subject_template = Liquid::Template.parse(action.template.subject)
        content_template = Liquid::Template.parse(action.template.content)
        order_drop = Drop::InsalesOrder.new(order)
        client_drop = Drop::InsalesClient.new(client)


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
        EventMailer.with(email_data).send_action_email.deliver_later(wait: wait.to_i.minutes)
      end
    end
  end
  
  def normalize_data_white_space
    self.attributes.each do |key, value|
      self[key] = value.squish if value.respond_to?("squish")
    end
  end

end
    
    
    