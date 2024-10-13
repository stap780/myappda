class Insint::Order < ApplicationService
  def initialize(tenant, datas)
    @tenant = tenant
    @datas = datas
  end

  def call
    Apartment::Tenant.switch(@tenant) do
      client_email = @datas["client"]["email"]
      client_phone = @datas["client"]["phone"]
      check_client = client_email.present? ? Client.find_by_email(client_email) : Client.find_by_phone(client_phone)
      client_data = {
        clientid: @datas["client"]["id"],
        email: client_email.present? ? client_email : "#{@datas["client"]["id"].to_s}@mail.ru",
        name: @datas["client"]["name"],
        phone: client_phone
      }
      check_client.update(client_data.except!(:email)) if check_client.present?
      client = check_client.present? ? check_client : Client.create!(client_data)

      # создаём запись о том что произошло изменение в заказе
      client.order_status_changes.create!(insales_order_id: @datas["id"],
        insales_order_number: @datas["number"],
        insales_custom_status_title: @datas["custom_status"]["title"],
        insales_financial_status: @datas["financial_status"])
      # конец запись о том что произошло изменение в заказе
      #
      # проверяем заявку и создаём или обновляем
      search_case = Mycase.where(client_id: client.id, insales_order_id: @datas["id"])
      # puts "search_case.id => " + search_case.first.id.to_s if search_case.present?
      mycase = search_case.present? ? search_case.update(insales_custom_status_title: @datas["custom_status"]["title"],
        insales_financial_status: @datas["financial_status"], status: "take")[0] :
                                      Mycase.create!(client_id: client.id, insales_order_id: @datas["id"],
                                        insales_custom_status_title: @datas["custom_status"]["title"],
                                        insales_financial_status: @datas["financial_status"],
                                        status: "new", casetype: "order", number: @datas["number"])
      puts "mycase => " + mycase.to_s
      puts mycase.is_a? Array
      @datas["order_lines"].each do |o_line|
        product = Product.find_by_insid(o_line["product_id"]).present? ? Product.find_by_insid(o_line["product_id"]) :
                                                                        Product.create!(insid: o_line["product_id"], 
                                                                                        title: o_line["title"])
        puts "insint order product => " + product.inspect
        variant = product.variants.where(insid: o_line["variant_id"]).present? ? product.variants.where(insid: o_line["variant_id"])[0] :
                                                                              product.variants.create!( insid: o_line["variant_id"],
                                                                                                        sku: o_line["sku"], 
                                                                                                        price: o_line["sale_price"])
        line = mycase.lines.where(product_id: product.id, variant_id: variant.id)
        if line.present?
          line.first.update!(quantity: o_line["quantity"], price: o_line["full_total_price"])
        else
          mycase.lines.create!(product_id: product.id, variant_id: variant.id, quantity: o_line["quantity"], price: o_line["full_total_price"])
        end
      end

      # конец проверяем заявку и создаём или обновляем

      mycase.do_event_action
      # конец создаём заявку
    end
  end

  private
end
