class Insint::Preorder < ApplicationService
  
  def initialize(tenant, datas)
    @tenant = tenant
    @datas = datas
  end

  def call
    Apartment::Tenant.switch(@tenant) do
      number = @datas['id']
      email = @datas['contacts']['email'].present? ? @datas['contacts']['email'] : "#{number}@mail.ru"
      phone = @datas['contacts']['phone'].present? ? @datas['contacts']['phone'] : '+79011111111'
      name = @datas['contacts']['name'].present? ? @datas['contacts']['name'] : "preorder_#{number}"
      ya_client =  @datas['contacts']['ya_client_id']
      check = Client.find_by_email(email)
      search_client = check.present? ? check : Client.find_by_phone(phone)
      client = search_client.present? ? search_client : Client.create!(email: email, phone: phone, name: name, ya_client: ya_client)
      mycase_data = {
        number: number,
        casetype: 'preorder',
        client_id: client.id,
        status: 'new'
      }
      mycase = Mycase.where(number: number).first_or_create!(mycase_data)
      puts "insint preorder mycase => #{mycase.inspect}"
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
      # NOTICE add record to preorders
      mycase.add_preorder
      # NOTICE do event action
      mycase.do_event_action
    end
  end
  
end
