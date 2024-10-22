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
        client_ids = Mycase.restocks.status_new.group(:client_id).count.map { |id, count| id } # .group_by { |m| m.client_id.to_s }
        puts "status #{ms&.status} // product_xml #{!ms&.product_xml.blank?} // client_ids #{client_ids.present?}"
        if ms&.status && !ms&.product_xml.blank? && clients.present?
          puts "запустили #{tenant}"
          RestockJob.perform_later(tenant, client_ids, ms.product_xml)
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
