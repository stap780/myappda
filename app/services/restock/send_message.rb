# frozen_string_literal: true

# We send messages to client.
class Restock::SendMessage < ApplicationService
  # Message have information about all client restocks from all mycases.
  # we send message only if client.restocks.for_inform.present? == true

  def initialize(tenant, client)
    @tenant = tenant
    @client = client
  end

  def call
    send_message
  end

  private

  def send_message
    Apartment::Tenant.switch(@tenant) do
      events = Event.active.restocks
      if events.exists?
        events.each do |event|
          user = User.find_by_subdomain(@tenant)
          action = event.event_actions.first
          channel = action.channel
          if channel == 'email'
            action_receiver = action.template.receiver
            receiver = action_receiver.blank? ? user.email : action_receiver
            receiver = @client.email if action_receiver == 'client'

            subject_template = Liquid::Template.parse(action.template.subject)
            content_template = Liquid::Template.parse(action.template.content)
            client_drop = Drops::Client.new(@client)
            restock_drop = Drops::Client.new(@client.restocks)
            subject = subject_template.render('client' => client_drop)
            content = content_template.render('client' => client_drop, 'restocks' => restock_drop)
            email_data = {
              user: user,
              subject: subject,
              content: content,
              receiver: receiver
            }
            EventMailer.with(email_data).send_action_email.deliver_later(wait: 1.minutes)
            @client.restocks.for_inform.each do |res|
              res.mycase.update(status: 'finish')
            end
            @client.restocks.for_inform.update_all(status: 'send')
            puts "   ====client have restocks and we inform it // client id => #{@client.id}"
          else
            puts '   ====client did not have restocks to inform'
          end
        end
      end
    end
  end

end
