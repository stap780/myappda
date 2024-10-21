#  encoding : utf-8
namespace :restock do
  desc "restock schedule update"

  task check_quantity_and_send_client_email: :environment do
    puts "start check_product_qt - время москва - #{Time.zone.now}"
    tenants = User.pluck(:subdomain)
    puts "=======всего tenants - #{tenants.count}"
    tenants.each do |tenant|
      ms = MessageSetup.first
      restock_cases_group_by_client = Mycase.restocks.where(status: "new").group_by(&:client_id)
      RestockJob.perform_now(tenant, restock_cases_group_by_client, ms.product_xml) if ms&.status && !ms&.product_xml.blank? && restock_cases.exists?
    end

    puts "finish check_product_qt - время москва - #{Time.zone.now}"
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
