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
      search_mycase = Mycase.find_by_number(number)
      mycase = search_mycase.present? ? search_mycase : Mycase.create!(number: number, casetype: 'abandoned_cart', client_id: client.id, status: 'new')

      puts "insint abandoned_cart mycase => #{mycase.inspect}"

      mycase.lines.delete_all # this we need to have last cart data if user change cart after several time

      @datas['lines'].each do |o_line|
        product = Product.find_by_insid(o_line['productId'].to_i).present? ? Product.find_by_insid(o_line['productId'].to_i) :
                                                                      Product.create!(insid: o_line['productId'].to_i)
        variant = product.variants.where(insid: o_line['variantId'].to_i).present? ? product.variants.where(insid: o_line['variantId'].to_i)[0] :
                                                                                product.variants.create!(insid: o_line['variantId'].to_i)

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
      mycase.do_event_action unless search_mycase.present?
    end
  end

end
