#  encoding : utf-8
namespace :client do
  desc "client update to new logic"

  task update: :environment do
    puts "start update_client - время москва - #{Time.zone.now}"
    # rake file:cut_file QUEUE="*" --trace > /var/www/myappda/shared/log/cut_file.log 2>&1
    tenants = User.pluck(:subdomain)
    tenants.each do |tenant|
      Apartment::Tenant.switch(tenant) do
        Client.order(:id).each do |client, i|
          sleep 60 if i == 100 || i == 200 || i == 300 || i == 400 || i == 500
          client.get_ins_client_data
        end
      end
    end

    puts "finish update_client - время москва - #{Time.zone.now}"
  end

end
