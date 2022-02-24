#  encoding : utf-8
namespace :product do
  desc "product update to new logic"

  task create_products: :environment do
    puts "start create_products - время москва - #{Time.zone.now}"
    # rake file:cut_file QUEUE="*" --trace > /var/www/myappda/shared/log/cut_file.log 2>&1
    tenants = User.pluck(:subdomain)
    tenants.each do |tenant|
      Apartment::Tenant.switch(tenant) do
        Client.order(:id).each do |client|
          izb_products = client.izb_productid.split(',')
          izb_products.each do |izb, i|
            sleep 1 if i == 200 || i == 400 || i == 600 || i == 800
            product = Product.find_or_create_by(insid: izb)
            client.client_products.create(product_id: product.id)
          end
        end
      end
    end

    puts "finish create_products - время москва - #{Time.zone.now}"
  end

end
