class Insint::Order
  def initialize(tenant, @params)
    @tenant = tenant
    @@params = @params
  end

  def call
    Apartment::Tenant.switch(saved_subdomain) do
  
      check_client = Client.find_by_email(@params["client"]["email"])
      client_data = {
        clientid: @params["client"]["id"],
        email: @params["client"]["email"],
        name: @params["client"]["name"],
        phone: @params["client"]["phone"]
      }
      check_client.update(client_data.except!(:email)) if check_client.present?
      client = check_client.present? ? check_client : Client.create!(client_data)

      # создаём запись о том что произошло изменение в заказе
      client.order_status_changes.create!(insales_order_id: @params["id"],
        insales_order_number: @params["number"],
        insales_custom_status_title: @params["custom_status"]["title"],
        insales_financial_status: @params["financial_status"])
      # конец запись о том что произошло изменение в заказе
      # 
      # проверяем заявку и создаём или обновляем
      search_case = Mycase.where(client_id: client.id, insales_order_id: @params["id"])
      # puts "search_case.id => " + search_case.first.id.to_s if search_case.present?
      mycase = search_case.present? ? search_case.update(insales_custom_status_title: @params["custom_status"]["title"],
        insales_financial_status: @params["financial_status"],status: "take")[0] :
                                      Mycase.create!(client_id: client.id, insales_order_id: @params["id"],
                                        insales_custom_status_title: @params["custom_status"]["title"],
                                        insales_financial_status: @params["financial_status"],
                                        status: "new", casetype: "order", number: @params["number"])
      puts "mycase => " + mycase.to_s
      puts mycase.is_a? Array
      @params["order_lines"].each do |o_line|
        product = Product.find_by_insid(o_line["product_id"]).present? ? Product.find_by_insid(o_line["product_id"]) :
                                                                        Product.create!(insid: o_line["product_id"])
        puts "insint order product => " + product.inspect
        variant = product.variants.where(insid: o_line["variant_id"]).present? ? product.variants.where(insid: o_line["variant_id"])[0] :
                                                                              product.variants.create!(insid: o_line["variant_id"])
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