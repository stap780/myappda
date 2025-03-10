# Insint::AbandonedCart
class Insint::AbandonedCart < ApplicationService

  def initialize(tenant, datas)
    @tenant = tenant
    @datas = datas
  end

  def call
    Apartment::Tenant.switch(@tenant) do
      number = @datas['id']
      email = @datas['contacts']['email']
      phone = @datas['contacts']['phone']
      name = @datas['contacts']['name'].present? ? @datas['contacts']['name'] : "abandoned_#{number}"
      search_client = Client.find_by_email(email).present? ? Client.find_by_email(email) : Client.find_by_phone(phone)

      client = search_client.present? ? search_client : Client.create!(email: email, phone: phone, name: name)

      # this we need for check Mycase present because we have action only to new abandoned cart
      check_case = Mycase.find_by_number(number)
      ######
      mycase_data = {
        number: number,
        casetype: 'abandoned_cart',
        client_id: client.id,
        status: 'new'
      }
      # mycase = search_mycase.present? ? search_mycase : Mycase.create!(mycase_data)
      mycase = Mycase.where(number: number).first_or_create!(mycase_data)

      puts "insint abandoned_cart mycase => #{mycase.inspect}"

      # this we need to have last cart data if user change cart after several time
      mycase.delete_lines_and_relation_abandoned if mycase.lines.size.positive?

      @datas['lines'].each do |o_line|
        product = Product.where(insid: o_line['productId']).first_or_create!
        variant = Variant.where(insid: o_line['variantId'], product_id: product.id).first_or_create!

        line = mycase.lines.where(product_id: product.id, variant_id: variant.id)
        line_data = {
          product_id: product.id,
          variant_id: variant.id,
          quantity: o_line['quantity'],
          price: o_line['full_total_price']
        }

        line.present? ? line.first.update!(line_data) : mycase.lines.create!(line_data)
      end

      mycase.add_abandoned_cart
      mycase.do_event_action unless check_case.present?
    end
  end

end
