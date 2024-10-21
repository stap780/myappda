class Restock::SendMessage < ApplicationService
  # We send messages to client.
  # Message have information about all client restocks from all mycases.

  def initialize(tenant, restock_cases_group_by_client, product_xml)
    @tenant = tenant
    @restock_cases_group_by_client = restock_cases_group_by_client
    @product_xml = product_xml
    @xml_file = ""
  end

  def call
    if check_product_xml_work
      @xml_file = load_products_xml
      restocks_update_status_for_inform
      send_message
    end
  end

  private

  def send_message
    Apartment::Tenant.switch(@tenant) do
      events = Event.active.restocks
      if events.exists?
        Variant.update_all(quantity: 0)
        uniq_records_ids = Restock.find_dups
        Restock.where.not(id: uniq_records_ids).delete_all
        @restock_cases_group_by_client.each do |rcg| # this is clients iteration
          client = Client.find(rcg[0])
          mycases = rcg[1]
          events.each do |event|
            user = User.find_by_subdomain(@tenant)
            action = event.event_actions.first
            channel = action.channel
            if channel == "email"
              receiver = if action.template.receiver == "client"
                client.email
              else
                action.template.receiver.blank? ? user.email : action.template.receiver
              end
              subject_template = Liquid::Template.parse(action.template.subject)
              content_template = Liquid::Template.parse(action.template.content)
              client_drop = Drops::Client.new(client)
              restock_drop = Drops::Client.new(client.restocks)
              subject = subject_template.render("client" => client_drop)
              content = content_template.render("client" => client_drop, "restocks" => restock_drop)
              email_data = {
                user: user,
                subject: subject,
                content: content,
                receiver: receiver
              }
              if client.restocks.for_inform.present?
                EventMailer.with(email_data).send_action_email.deliver_later(wait: 1.minutes)
                client.restocks.for_inform.update_all(status: "send")
                mycases.each do |mycase|
                  mycase.update(status: "finish")
                end
                puts "=======client have restocks and we inform it"
                puts "=======client id => " + @client.id.to_s
              else
                puts "=======client didn't have restocks to inform"
              end
            end
          end
        end
      end
    end
  end

  def check_product_xml_work
    check = true
    begin
      response = RestClient.get(@product_xml)
    rescue SocketError => e
      puts "In Socket errror"
      puts e
      check = false
    rescue => e
      puts(e.class.inspect)
      check = false
    else
      check
    end
  end

  def load_products_xml
    filename = @product_xml.split("/").last
    download_path = Rails.env.development? ? "#{Rails.root}/public/#{filename}" : "/var/www/myappda/shared/public/#{filename}"
    File.delete(download_path) if File.file?(download_path).present?
    file = ""
    RestClient.get(@product_xml) { |response, request, result, &block|
      # puts response.code
      # puts response
      case response.code
      when 200
        f = File.new(download_path, "wb")
        f << response.body
        f.close
        file = download_path
      when 301
        puts "load_products_xml error 301"
      else
        response.return!(&block)
      end
    }
    file
  end

  def restocks_update_status_for_inform
    if File.file?(@xml_file).present?
      Apartment::Tenant.switch(@tenant) do
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
