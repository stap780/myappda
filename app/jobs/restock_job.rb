class RestockJob < ApplicationJob
  queue_as :restock_job
  sidekiq_options retry: 0

  def perform(tenant, clients, product_xml)

    Restock::SendMessage.new(tenant, clients, product_xml).call

    # Apartment::Tenant.switch(tenant) do
    #   if product_xml&.check_product_xml_work(product_xml)
    #     events = Event.active.where(casetype: "restock")
    #     clients = Client.with_restocks
    #     puts "=======start check clients / всего clients - #{clients.count}"
    #     Variant.update_all(quantity: 0)
    #     uniq_records_ids = Restock.find_dups
    #     Restock.where.not(id: uniq_records_ids).delete_all
    #     xml_file = load_products_xml(product_xml)
    #     if clients.present? && xml_file.present?
    #       user = User.find_by_subdomain(tenant)
    #       clients.each do |client|
    #         RestockSendMessageJob.perform_later(user, client, events, xml_file)
    #       end
    #     end
    #   end
    # end
  end

  # private

  # def check_product_xml_work(link)
  #   check = true
  #   begin
  #     response = RestClient.get(link)
  #   rescue SocketError => e
  #     puts "In Socket errror"
  #     puts e
  #     check = false
  #   rescue => e
  #     puts(e.class.inspect)
  #     check = false
  #   else
  #     check
  #   end
  # end

  # def load_products_xml(link)
  #   filename = link.split("/").last
  #   download_path = Rails.env.development? ? "#{Rails.root}/public/#{filename}" : "/var/www/myappda/shared/public/#{filename}"
  #   File.delete(download_path) if File.file?(download_path).present?
  #   file = ""
  #   RestClient.get(product_xml) { |response, request, result, &block|
  #     # puts response.code
  #     # puts response
  #     case response.code
  #     when 200
  #       f = File.new(download_path, "wb")
  #       f << response.body
  #       f.close
  #       file = download_path
  #     when 301
  #       puts "load_products_xml error 301"
  #     else
  #       response.return!(&block)
  #     end
  #   }
  #   file
  # end

end
