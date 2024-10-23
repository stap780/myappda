#  encoding : utf-8
namespace :restock do
  desc "restock schedule update"

  task check_quantity_and_send_client_email: :environment do
    puts "###### start check_product_qt - время москва - #{Time.zone.now}"
    tenants = User.order(:id).pluck(:subdomain)
    puts "=======всего tenants - #{tenants.count}"
    tenants.each do |tenant|
      Apartment::Tenant.switch(tenant) do
        puts "======="
        ms = MessageSetup.first
        client_ids = Mycase.restocks.status_new.group(:client_id).count.map { |id, count| id }
        puts "status #{ms&.status} // product_xml #{!ms&.product_xml.blank?} // client_ids #{client_ids.present?}"
        if ms&.status && !ms&.product_xml.blank? && client_ids.present?
          puts "запустили #{tenant}"
          clients = Client.where(id: client_ids)
          xml_file = Restock::GetFile.call(product_xml)
          if xml_file.present?
            # Variant.update_all(quantity: 0)
            # uniq_records_ids = Restock.find_dups
            # Restock.where.not(id: uniq_records_ids).delete_all
            clients.each do |client|
              RestockSendMessageJob.perform_later(tenant, client, xml_file)
            end
          end
        else
          puts "не запустили #{tenant}"
        end
      end
    end

    puts "###### finish check_product_qt - время москва - #{Time.zone.now}"
  end
end

# testing
# tenant = 'teletri'
# Apartment::Tenant.switch!(tenant)
# user = User.find_by_subdomain(tenant)
# product_xml = MessageSetup.first.product_xml
# client = Client.find 13
# events = Event.active.where(casetype: 'restock')
# RestockService.new(user, client, events, product_xml).do_action
