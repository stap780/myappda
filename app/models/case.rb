class Case < ApplicationRecord
    belongs_to :client
    has_many :products, through: :lines
    has_many :variants, through: :lines
    has_many :lines
    accepts_nested_attributes_for :lines, allow_destroy: true #,reject_if: proc { |attributes| attributes['weight'].blank? }
  
    before_save :normalize_data_white_space
    after_commit :do_event_action, on: [:create]

    CASETYPE = [['order','order'],['restock','restock'],['abandoned_cart','abandoned_cart'],['preoder','preoder']].freeze
    STATUS = [['new','new'],['take','take'],['finish','finish']].freeze


    private

    def do_event_action
        if self.casetype != 'order'
            events = Event.where(casetype: self.casetype)
            if events.present?
                puts "case do_event_action"
                user = User.find_by_subdomain(Apartment::Tenant.current)
                events.each do |event|
                    action = event.event_actions.first
                    channel = action.channel
                    operation = action.operation
                    pause = action.pause
                    pause_time = action.pause_time
                    timetable = action.timetable
                    receiver = self.client.email if action.template.receiver == 'client'
                    receiver = user.email if action.template.receiver == 'manager'
        
                    subject_template = Liquid::Template.parse(action.template.subject)
                    content_template = Liquid::Template.parse(action.template.content)
                    case_drop = Services::Drop::Case.new(self)
                    client_drop = Services::Drop::Client.new(self.client)
        
        
                    subject = subject_template.render('case' => case_drop, 'client' => client_drop)
                    content = content_template.render('case' => case_drop, 'client' => client_drop)
                    
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
    
    
    