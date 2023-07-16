#  encoding : utf-8
namespace :restock do
    desc "restock schedule update"
  
    task check_quantity_and_send_client_email: :environment do
      puts "start check_product_qt - время москва - #{Time.zone.now}"
      tenants = User.pluck(:subdomain)
      tenants.each do |tenant|
        Apartment::Tenant.switch(tenant) do
            user = User.find_by_subdomain(tenant)
            if MessageSetup.all.count > 0
              product_xml = MessageSetup.first.product_xml
              events = Event.where(casetype: 'restock')
              clients = Client.with_restocks
              clients.each do |client|
                  Services::Restock.new(user, client, events, product_xml).do_action
              end
            end
        end #if tenant == 'test2'
      end
  
      puts "finish check_product_qt - время москва - #{Time.zone.now}"
    end
  
  end