#  encoding : utf-8
class RestockService
  def initialize(user, client, events, xml_file)
    @user = user
    @client = client
    @events = events
    # @product_xml = product_xml
    @xml_file = xml_file #Rails.env.development? ? "#{Rails.root}/public/#{@user.id}.xml" : "/var/www/myappda/shared/public/#{@user.id}.xml"
  end

  def do_action # (user, client, events)
    @events.each do |event|
      action = event.event_actions.first
      channel = action.channel
      # operation = action.operation
      # pause = action.pause
      # pause_time = action.pause_time
      # timetable = action.timetable
      # timetable_time = action.timetable_time
      receiver = @client.email if action.template.receiver == "client"
      receiver = @user.email if action.template.receiver == "manager"

      # wait = (pause == true && pause_time.present?) ? pause_time : 1
      # table_hour = (timetable == true && timetable_time.present?) ? timetable_time.to_i / 60 : 12
      # periods = Array.new((23 / table_hour) + 1) { |e| table_hour * e }.reject(&:blank?)
      # now_hour = Time.now.strftime("%H")

      # if periods.include?(now_hour.to_i)

        restocks_update_status_for_inform # we set status READY

        subject_template = Liquid::Template.parse(action.template.subject)
        content_template = Liquid::Template.parse(action.template.content)

        client_drop = Drops::Client.new(@client)
        restock_drop = Drops::Client.new(@client.restocks)

        subject = subject_template.render("client" => client_drop)
        content = content_template.render("client" => client_drop, "restocks" => restock_drop)

        email_data = {
          user: @user,
          subject: subject,
          content: content,
          receiver: receiver
        }

        if @client.restocks.for_inform.present?
          EventMailer.with(email_data).send_action_email.deliver_later(wait: wait.to_i.minutes) if channel == "email"
          @client.restocks.for_inform.update_all(status: "send")
          Mycase.restock_update_cases(@client)
          puts "=======client have restocks and we inform it"
          puts "=======client id => " + @client.id.to_s
        else
          puts "=======don't have restocks to inform client"
        end
      # else
      #   puts "не наш период now_hour #{now_hour}, periods #{periods}, table_hour #{table_hour}"
      # end
    end
  end

  def restocks_update_status_for_inform
    if File.file?(@xml_file).present?
      Apartment::Tenant.switch(@user.subdomain) do
        all_offers = Nokogiri::XML(File.open(@xml_file)).xpath("//offer")
        Restock.status_wait.each do |res|
          ins_variant = all_offers.select { |offer| offer if offer["id"] == res.variant.insid.to_s }
          if ins_variant.present? && ins_variant[0]["available"] == "true"
            puts "=======restocks_update_status_for_inform #{res.inspect}"
            res.update!(status: "ready")
          end
        end
      end
    end
  end

end
