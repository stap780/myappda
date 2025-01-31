# Insint::Restock < ApplicationService
class Insint::Restock < ApplicationService
  
  def initialize(tenant, datas)
    @tenant = tenant
    @datas = datas
  end

  def call
    Apartment::Tenant.switch(@tenant) do
      number = @datas['id']
      search_client = Client.find_by_email(@datas['contacts']['email']).present? ? Client.find_by_email(@datas['contacts']['email']) :
                                                                                  Client.find_by_phone(@datas['contacts']['phone'])
      client_name = @datas['contacts']['name'].present? ? @datas['contacts']['name'] : "restock_#{number}"
      phone = @datas['contacts']['phone'].present? ? @datas['contacts']['phone'] : '+79011111111'
      client = search_client.present? ? search_client : Client.create!(email: @datas['contacts']['email'], phone: phone, name: client_name)
      mycase_data = {
        number: number,
        casetype: 'restock',
        client_id: client.id,
        status: 'new'
      }
      # mycase = Mycase.find_by_number(number).present? ? Mycase.find_by_number(number) :
      #                                               Mycase.create!(number: number, casetype: "restock", client_id: client.id, status: "new")
      mycase = Mycase.where(number: number).first_or_create!(mycase_data)
      puts "insint restock mycase => #{mycase.inspect}"
      @datas['lines'].each do |o_line|
        # product = Product.find_by_insid(o_line['productId']).present? ? Product.find_by_insid(o_line['productId']) :
        #                                                               Product.create!(insid: o_line['productId'])
        product = Product.where(insid: o_line['productId']).first_or_create!
        # variant = product.variants.where(insid: o_line['variantId']).present? ? product.variants.where(insid: o_line['variantId'])[0] :
        #                                                                       product.variants.create!(insid: o_line['variantId'])
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
      mycase.add_restock
    end
  end
  
end
