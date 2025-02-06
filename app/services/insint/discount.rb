# This class is responsible for applying discounts to insales order by api
class Insint::Discount < ApplicationService

  def initialize(saved_subdomain, datas)
    @user = User.find_by_subdomain(saved_subdomain)
    @saved_subdomain = saved_subdomain
    @datas = datas
  end

  def call
    puts "Insint::Discount time now => #{Time.now}"
    add_collection_title_to_datas
    sleep 0.5
    data = get_discount
    puts "Insint::Discount get_discount data => #{data}"
    puts "     data.present? => #{data.present?}"
    if data.present?
      [true, data]
    else
      error_data = {
        "errors": ['нет условий для скидки']
      }
      [true, error_data]
    end
  end

  private

  def get_discount
    Apartment::Tenant.switch(@saved_subdomain) do
      data = {}
      Discount.order(position: :asc).each do |discount|
        result = false
        template = Liquid::Template.parse(discount.rule)
        context = @datas.respond_to?(:deep_stringify_keys) ? @datas.deep_stringify_keys : @datas.to_hash
        # puts "check discount context => #{context}"
        html_as_string = template.render!(context, { strict_variables: true })
        puts "check discount html_as_string => #{html_as_string}"
        check = html_as_string.squish if html_as_string.respond_to?(:squish)
        puts "check discount condition => #{check}"
        if check.include?('do_work')
          data['discount'] = discount.shift
          data['discount_type'] = discount.points.upcase
          data['title'] = discount.notice
          result = true
        end

        break if result
      end
      data
    end
  end

  def add_collection_title_to_datas
    user = User.find_by_subdomain(@saved_subdomain)
    service = ApiInsales.new(user.insints.first)

    return unless service.work?

    @datas['order_lines'].each do |line|
      product = service.get_product_data(line['product_id'])
      cols_titlies = product.collections_ids.map{|id| InsalesApi::Collection.find(id).title }
      line['colls'] = cols_titlies
    end
  end

end



# Test
# datas1 = {"fields_values"=>[], "order_lines"=>[{"id"=>nil, "order_id"=>nil, "sale_price"=>1500.0, "full_sale_price"=>1500.0, "total_price"=>1500.0, "full_total_price"=>1500.0, "discounts_amount"=>0.0, "quantity"=>1, "reserved_quantity"=>nil, "weight"=>"1.0", "dimensions"=>nil, "variant_id"=>297350445, "product_id"=>173896994, "sku"=>"2001", "barcode"=>nil, "title"=>"Демо-товар 2", "unit"=>"pce", "comment"=>nil, "updated_at"=>nil, "created_at"=>nil, "bundle_id"=>nil, "vat"=>-1, "fiscal_product_type"=>1, "requires_marking"=>nil, "marking_codes"=>nil, "accessory_lines"=>[], "external_variant_id"=>nil}, {"id"=>nil, "order_id"=>nil, "sale_price"=>12000.0, "full_sale_price"=>12000.0, "total_price"=>12000.0, "full_total_price"=>12000.0, "discounts_amount"=>0.0, "quantity"=>1, "reserved_quantity"=>nil, "weight"=>nil, "dimensions"=>nil, "variant_id"=>631514614, "product_id"=>375725930, "sku"=>nil, "barcode"=>nil, "title"=>"Куртка", "unit"=>"pce", "comment"=>nil, "updated_at"=>nil, "created_at"=>nil, "bundle_id"=>nil, "vat"=>-1, "fiscal_product_type"=>1, "requires_marking"=>nil, "marking_codes"=>nil, "accessory_lines"=>[], "external_variant_id"=>nil}, {"id"=>nil, "order_id"=>nil, "sale_price"=>33000.0, "full_sale_price"=>33000.0, "total_price"=>33000.0, "full_total_price"=>33000.0, "discounts_amount"=>0.0, "quantity"=>1, "reserved_quantity"=>nil, "weight"=>nil, "dimensions"=>nil, "variant_id"=>481328508, "product_id"=>274959127, "sku"=>"9800", "barcode"=>nil, "title"=>"Жакет из экокожи (l)", "unit"=>"pce", "comment"=>nil, "updated_at"=>nil, "created_at"=>nil, "bundle_id"=>nil, "vat"=>-1, "fiscal_product_type"=>1, "requires_marking"=>nil, "marking_codes"=>nil, "accessory_lines"=>[], "external_variant_id"=>nil}], "order_changes"=>[], "discount"=>nil, "shipping_address"=>{"id"=>nil, "fields_values"=>[], "name"=>nil, "surname"=>nil, "middlename"=>nil, "phone"=>nil, "formatted_phone"=>nil, "full_name"=>"", "full_locality_name"=>"г Москва", "full_delivery_address"=>"г Москва", "address_for_gis"=>"г Москва", "location_valid"=>true, "recipient_fields"=>[{"id"=>12483149, "destiny"=>2, "position"=>1, "office_title"=>"Имя", "for_buyer"=>true, "obligatory"=>true, "active"=>true, "system_name"=>"name", "created_at"=>"2020-02-19T16:22:10.378+03:00", "updated_at"=>"2020-02-19T16:22:10.378+03:00", "show_in_result"=>true, "show_in_checkout"=>true, "is_indexed"=>nil, "hide_in_backoffice"=>nil, "handle"=>nil, "title"=>nil, "example"=>nil, "type"=>"Field::ObligatoryTextField"}, {"id"=>26940520, "destiny"=>6, "position"=>1, "office_title"=>"Телефон", "for_buyer"=>true, "obligatory"=>true, "active"=>true, "system_name"=>"phone", "created_at"=>"2023-04-21T17:04:34.192+03:00", "updated_at"=>"2023-04-21T17:04:34.192+03:00", "show_in_result"=>true, "show_in_checkout"=>true, "is_indexed"=>nil, "hide_in_backoffice"=>nil, "handle"=>nil, "title"=>nil, "example"=>"", "type"=>"Field::Phone"}], "backoffice_fields"=>[{"id"=>12483148, "destiny"=>1, "position"=>2, "office_title"=>"Населенный пункт", "for_buyer"=>true, "obligatory"=>true, "active"=>true, "system_name"=>"full_locality_name", "created_at"=>"2020-02-19T16:22:10.372+03:00", "updated_at"=>"2020-02-19T16:22:10.372+03:00", "show_in_result"=>true, "show_in_checkout"=>true, "is_indexed"=>nil, "hide_in_backoffice"=>nil, "handle"=>nil, "title"=>nil, "example"=>nil, "type"=>"Field::Locality"}, {"id"=>12483154, "destiny"=>1, "position"=>5, "office_title"=>"Адрес", "for_buyer"=>true, "obligatory"=>false, "active"=>true, "system_name"=>"address", "created_at"=>"2020-02-19T16:22:10.409+03:00", "updated_at"=>"2020-02-19T16:22:10.409+03:00", "show_in_result"=>true, "show_in_checkout"=>true, "is_indexed"=>nil, "hide_in_backoffice"=>nil, "handle"=>nil, "title"=>nil, "example"=>nil, "type"=>"Field::SystemTextArea"}], "no_delivery"=>false, "kladr_autodetected_address"=>"101000, Россия, г Москва", "country_options"=>[{"code"=>"RU", "title"=>"Россия", "selected"=>false}], "address"=>nil, "country"=>nil, "state"=>"г Москва", "city"=>"Москва", "zip"=>nil, "street"=>nil, "house"=>nil, "flat"=>nil, "entrance"=>nil, "doorphone"=>nil, "floor"=>nil, "kladr_json"=>{"kladr_code"=>"7700000000000", "zip"=>"101000", "kladr_zip"=>nil, "region_zip"=>"101000", "country"=>"RU", "state"=>"Москва", "state_type"=>"г", "area"=>nil, "area_type"=>nil, "city"=>"Москва", "city_type"=>"г", "settlement"=>nil, "settlement_type"=>nil, "result"=>"г Москва", "latitude"=>"55.58422718163563", "longitude"=>"37.385272499999985", "autodetected"=>nil}, "location"=>{"kladr_code"=>"7700000000000", "zip"=>nil, "kladr_zip"=>"101000", "region_zip"=>"101000", "country"=>"RU", "state"=>"Москва", "state_type"=>"г", "area"=>nil, "area_type"=>nil, "city"=>"Москва", "city_type"=>"г", "settlement"=>nil, "settlement_type"=>nil, "address"=>"", "street"=>nil, "street_type"=>nil, "house"=>nil, "flat"=>nil, "is_kladr"=>true, "latitude"=>"55.58422718163563", "longitude"=>"37.385272499999985", "autodetected"=>nil}}, "client"=>{"id"=>nil, "email"=>nil, "name"=>nil, "phone"=>nil, "created_at"=>nil, "updated_at"=>nil, "comment"=>nil, "registered"=>false, "subscribe"=>true, "client_group_id"=>nil, "surname"=>nil, "middlename"=>nil, "bonus_points"=>0, "type"=>"Client::Individual", "correspondent_account"=>nil, "settlement_account"=>nil, "consent_to_personal_data"=>nil, "o_auth_provider"=>nil, "messenger_subscription"=>nil, "contact_name"=>nil, "progressive_discount"=>nil, "group_discount"=>nil, "ip_addr"=>"", "fields_values"=>[]}, "discounts"=>[], "total_price"=>46500.0, "items_price"=>46500.0, "id"=>nil, "key"=>nil, "number"=>nil, "comment"=>nil, "archived"=>false, "delivery_title"=>nil, "delivery_description"=>nil, "delivery_price"=>0.0, "full_delivery_price"=>0.0, "payment_description"=>nil, "payment_title"=>nil, "first_referer"=>nil, "first_current_location"=>"/close_editor?path=%2Fproduct%2Fpanasonic-br-agcf2w%3Flang%3Dru", "first_query"=>nil, "first_source_domain"=>nil, "first_source"=>"", "referer"=>nil, "current_location"=>"/close_editor?path=%2Fproduct%2Fpanasonic-br-agcf2w%3Flang%3Dru", "query"=>nil, "source_domain"=>nil, "source"=>"", "fulfillment_status"=>"new", "custom_status"=>{"permalink"=>"novyy", "title"=>"Новый"}, "delivered_at"=>nil, "accepted_at"=>nil, "created_at"=>nil, "updated_at"=>nil, "financial_status"=>"pending", "delivery_date"=>nil, "delivery_from_hour"=>nil, "delivery_from_minutes"=>nil, "delivery_to_hour"=>nil, "delivery_to_minutes"=>nil, "delivery_time"=>"", "paid_at"=>nil, "delivery_variant_id"=>nil, "payment_gateway_id"=>nil, "margin"=>"0.0", "margin_amount"=>"0.0", "client_transaction_id"=>nil, "currency_code"=>"RUR", "cookies"=>nil, "account_id"=>784184, "manager_comment"=>nil, "locale"=>"ru", "delivery_info"=>{"delivery_variant_id"=>0, "tariff_id"=>nil, "title"=>nil, "description"=>nil, "price"=>nil, "shipping_company"=>nil, "shipping_company_handle"=>nil, "delivery_interval"=>{"min_days"=>nil, "max_days"=>nil, "description"=>""}, "errors"=>[], "warnings"=>[], "outlet"=>{"id"=>nil, "external_id"=>nil, "latitude"=>nil, "longitude"=>nil, "title"=>nil, "description"=>nil, "address"=>nil, "payment_method"=>[], "source_id"=>nil}, "not_available"=>nil}, "responsible_user_id"=>nil, "total_profit"=>"46500.0", "insint"=>{"id"=>nil, "created_at"=>nil, "updated_at"=>nil}}
# datas2 = {"fields_values"=>[], "order_lines"=>[{"id"=>nil, "order_id"=>nil, "sale_price"=>1500.0, "full_sale_price"=>1500.0, "total_price"=>1500.0, "full_total_price"=>1500.0, "discounts_amount"=>0.0, "quantity"=>1, "reserved_quantity"=>nil, "weight"=>"1.0", "dimensions"=>nil, "variant_id"=>297350445, "product_id"=>173896994, "sku"=>"2001", "barcode"=>nil, "title"=>"Демо-товар 2", "unit"=>"pce", "comment"=>nil, "updated_at"=>nil, "created_at"=>nil, "bundle_id"=>nil, "vat"=>-1, "fiscal_product_type"=>1, "requires_marking"=>nil, "marking_codes"=>nil, "accessory_lines"=>[], "external_variant_id"=>nil}, {"id"=>nil, "order_id"=>nil, "sale_price"=>12000.0, "full_sale_price"=>12000.0, "total_price"=>12000.0, "full_total_price"=>12000.0, "discounts_amount"=>0.0, "quantity"=>1, "reserved_quantity"=>nil, "weight"=>nil, "dimensions"=>nil, "variant_id"=>631514614, "product_id"=>375725930, "sku"=>nil, "barcode"=>nil, "title"=>"Куртка", "unit"=>"pce", "comment"=>nil, "updated_at"=>nil, "created_at"=>nil, "bundle_id"=>nil, "vat"=>-1, "fiscal_product_type"=>1, "requires_marking"=>nil, "marking_codes"=>nil, "accessory_lines"=>[], "external_variant_id"=>nil}], "order_changes"=>[], "discount"=>nil, "shipping_address"=>{"id"=>nil, "fields_values"=>[], "name"=>nil, "surname"=>nil, "middlename"=>nil, "phone"=>nil, "formatted_phone"=>nil, "full_name"=>"", "full_locality_name"=>"г Москва", "full_delivery_address"=>"г Москва", "address_for_gis"=>"г Москва", "location_valid"=>true, "recipient_fields"=>[{"id"=>12483149, "destiny"=>2, "position"=>1, "office_title"=>"Имя", "for_buyer"=>true, "obligatory"=>true, "active"=>true, "system_name"=>"name", "created_at"=>"2020-02-19T16:22:10.378+03:00", "updated_at"=>"2020-02-19T16:22:10.378+03:00", "show_in_result"=>true, "show_in_checkout"=>true, "is_indexed"=>nil, "hide_in_backoffice"=>nil, "handle"=>nil, "title"=>nil, "example"=>nil, "type"=>"Field::ObligatoryTextField"}, {"id"=>26940520, "destiny"=>6, "position"=>1, "office_title"=>"Телефон", "for_buyer"=>true, "obligatory"=>true, "active"=>true, "system_name"=>"phone", "created_at"=>"2023-04-21T17:04:34.192+03:00", "updated_at"=>"2023-04-21T17:04:34.192+03:00", "show_in_result"=>true, "show_in_checkout"=>true, "is_indexed"=>nil, "hide_in_backoffice"=>nil, "handle"=>nil, "title"=>nil, "example"=>"", "type"=>"Field::Phone"}], "backoffice_fields"=>[{"id"=>12483148, "destiny"=>1, "position"=>2, "office_title"=>"Населенный пункт", "for_buyer"=>true, "obligatory"=>true, "active"=>true, "system_name"=>"full_locality_name", "created_at"=>"2020-02-19T16:22:10.372+03:00", "updated_at"=>"2020-02-19T16:22:10.372+03:00", "show_in_result"=>true, "show_in_checkout"=>true, "is_indexed"=>nil, "hide_in_backoffice"=>nil, "handle"=>nil, "title"=>nil, "example"=>nil, "type"=>"Field::Locality"}, {"id"=>12483154, "destiny"=>1, "position"=>5, "office_title"=>"Адрес", "for_buyer"=>true, "obligatory"=>false, "active"=>true, "system_name"=>"address", "created_at"=>"2020-02-19T16:22:10.409+03:00", "updated_at"=>"2020-02-19T16:22:10.409+03:00", "show_in_result"=>true, "show_in_checkout"=>true, "is_indexed"=>nil, "hide_in_backoffice"=>nil, "handle"=>nil, "title"=>nil, "example"=>nil, "type"=>"Field::SystemTextArea"}], "no_delivery"=>false, "kladr_autodetected_address"=>"101000, Россия, г Москва", "country_options"=>[{"code"=>"RU", "title"=>"Россия", "selected"=>false}], "address"=>nil, "country"=>nil, "state"=>"г Москва", "city"=>"Москва", "zip"=>nil, "street"=>nil, "house"=>nil, "flat"=>nil, "entrance"=>nil, "doorphone"=>nil, "floor"=>nil, "kladr_json"=>{"kladr_code"=>"7700000000000", "zip"=>"101000", "kladr_zip"=>nil, "region_zip"=>"101000", "country"=>"RU", "state"=>"Москва", "state_type"=>"г", "area"=>nil, "area_type"=>nil, "city"=>"Москва", "city_type"=>"г", "settlement"=>nil, "settlement_type"=>nil, "result"=>"г Москва", "latitude"=>"55.58422718163563", "longitude"=>"37.385272499999985", "autodetected"=>nil}, "location"=>{"kladr_code"=>"7700000000000", "zip"=>nil, "kladr_zip"=>"101000", "region_zip"=>"101000", "country"=>"RU", "state"=>"Москва", "state_type"=>"г", "area"=>nil, "area_type"=>nil, "city"=>"Москва", "city_type"=>"г", "settlement"=>nil, "settlement_type"=>nil, "address"=>"", "street"=>nil, "street_type"=>nil, "house"=>nil, "flat"=>nil, "is_kladr"=>true, "latitude"=>"55.58422718163563", "longitude"=>"37.385272499999985", "autodetected"=>nil}}, "client"=>{"id"=>nil, "email"=>nil, "name"=>nil, "phone"=>nil, "created_at"=>nil, "updated_at"=>nil, "comment"=>nil, "registered"=>false, "subscribe"=>true, "client_group_id"=>nil, "surname"=>nil, "middlename"=>nil, "bonus_points"=>0, "type"=>"Client::Individual", "correspondent_account"=>nil, "settlement_account"=>nil, "consent_to_personal_data"=>nil, "o_auth_provider"=>nil, "messenger_subscription"=>nil, "contact_name"=>nil, "progressive_discount"=>nil, "group_discount"=>nil, "ip_addr"=>"", "fields_values"=>[]}, "discounts"=>[], "total_price"=>46500.0, "items_price"=>46500.0, "id"=>nil, "key"=>nil, "number"=>nil, "comment"=>nil, "archived"=>false, "delivery_title"=>nil, "delivery_description"=>nil, "delivery_price"=>0.0, "full_delivery_price"=>0.0, "payment_description"=>nil, "payment_title"=>nil, "first_referer"=>nil, "first_current_location"=>"/close_editor?path=%2Fproduct%2Fpanasonic-br-agcf2w%3Flang%3Dru", "first_query"=>nil, "first_source_domain"=>nil, "first_source"=>"", "referer"=>nil, "current_location"=>"/close_editor?path=%2Fproduct%2Fpanasonic-br-agcf2w%3Flang%3Dru", "query"=>nil, "source_domain"=>nil, "source"=>"", "fulfillment_status"=>"new", "custom_status"=>{"permalink"=>"novyy", "title"=>"Новый"}, "delivered_at"=>nil, "accepted_at"=>nil, "created_at"=>nil, "updated_at"=>nil, "financial_status"=>"pending", "delivery_date"=>nil, "delivery_from_hour"=>nil, "delivery_from_minutes"=>nil, "delivery_to_hour"=>nil, "delivery_to_minutes"=>nil, "delivery_time"=>"", "paid_at"=>nil, "delivery_variant_id"=>nil, "payment_gateway_id"=>nil, "margin"=>"0.0", "margin_amount"=>"0.0", "client_transaction_id"=>nil, "currency_code"=>"RUR", "cookies"=>nil, "account_id"=>784184, "manager_comment"=>nil, "locale"=>"ru", "delivery_info"=>{"delivery_variant_id"=>0, "tariff_id"=>nil, "title"=>nil, "description"=>nil, "price"=>nil, "shipping_company"=>nil, "shipping_company_handle"=>nil, "delivery_interval"=>{"min_days"=>nil, "max_days"=>nil, "description"=>""}, "errors"=>[], "warnings"=>[], "outlet"=>{"id"=>nil, "external_id"=>nil, "latitude"=>nil, "longitude"=>nil, "title"=>nil, "description"=>nil, "address"=>nil, "payment_method"=>[], "source_id"=>nil}, "not_available"=>nil}, "responsible_user_id"=>nil, "total_profit"=>"46500.0", "insint"=>{"id"=>nil, "created_at"=>nil, "updated_at"=>nil}}
# discount = {"fields_values"=>[], "order_lines"=>[{"id"=>nil, "order_id"=>nil, "sale_price"=>1500.0, "full_sale_price"=>1500.0, "total_price"=>1500.0, "full_total_price"=>1500.0, "discounts_amount"=>0.0, "quantity"=>1, "reserved_quantity"=>nil, "weight"=>"1.0", "dimensions"=>nil, "variant_id"=>297350445, "product_id"=>173896994, "sku"=>"2001", "barcode"=>nil, "title"=>"Демо-товар 2", "unit"=>"pce", "comment"=>nil, "updated_at"=>nil, "created_at"=>nil, "bundle_id"=>nil, "vat"=>-1, "fiscal_product_type"=>1, "requires_marking"=>nil, "marking_codes"=>nil, "accessory_lines"=>[], "external_variant_id"=>nil}, {"id"=>nil, "order_id"=>nil, "sale_price"=>12000.0, "full_sale_price"=>12000.0, "total_price"=>12000.0, "full_total_price"=>12000.0, "discounts_amount"=>0.0, "quantity"=>1, "reserved_quantity"=>nil, "weight"=>nil, "dimensions"=>nil, "variant_id"=>631514614, "product_id"=>375725930, "sku"=>nil, "barcode"=>nil, "title"=>"Куртка", "unit"=>"pce", "comment"=>nil, "updated_at"=>nil, "created_at"=>nil, "bundle_id"=>nil, "vat"=>-1, "fiscal_product_type"=>1, "requires_marking"=>nil, "marking_codes"=>nil, "accessory_lines"=>[], "external_variant_id"=>nil}, {"id"=>nil, "order_id"=>nil, "sale_price"=>33000.0, "full_sale_price"=>33000.0, "total_price"=>33000.0, "full_total_price"=>33000.0, "discounts_amount"=>0.0, "quantity"=>1, "reserved_quantity"=>nil, "weight"=>nil, "dimensions"=>nil, "variant_id"=>481328508, "product_id"=>274959127, "sku"=>"9800", "barcode"=>nil, "title"=>"Жакет из экокожи (l)", "unit"=>"pce", "comment"=>nil, "updated_at"=>nil, "created_at"=>nil, "bundle_id"=>nil, "vat"=>-1, "fiscal_product_type"=>1, "requires_marking"=>nil, "marking_codes"=>nil, "accessory_lines"=>[], "external_variant_id"=>nil}], "order_changes"=>[], "discount"=>nil, "shipping_address"=>{"id"=>nil, "fields_values"=>[], "name"=>nil, "surname"=>nil, "middlename"=>nil, "phone"=>nil, "formatted_phone"=>nil, "full_name"=>"", "full_locality_name"=>"г Москва", "full_delivery_address"=>"г Москва", "address_for_gis"=>"г Москва", "location_valid"=>true, "recipient_fields"=>[{"id"=>12483149, "destiny"=>2, "position"=>1, "office_title"=>"Имя", "for_buyer"=>true, "obligatory"=>true, "active"=>true, "system_name"=>"name", "created_at"=>"2020-02-19T16:22:10.378+03:00", "updated_at"=>"2020-02-19T16:22:10.378+03:00", "show_in_result"=>true, "show_in_checkout"=>true, "is_indexed"=>nil, "hide_in_backoffice"=>nil, "handle"=>nil, "title"=>nil, "example"=>nil, "type"=>"Field::ObligatoryTextField"}, {"id"=>26940520, "destiny"=>6, "position"=>1, "office_title"=>"Телефон", "for_buyer"=>true, "obligatory"=>true, "active"=>true, "system_name"=>"phone", "created_at"=>"2023-04-21T17:04:34.192+03:00", "updated_at"=>"2023-04-21T17:04:34.192+03:00", "show_in_result"=>true, "show_in_checkout"=>true, "is_indexed"=>nil, "hide_in_backoffice"=>nil, "handle"=>nil, "title"=>nil, "example"=>"", "type"=>"Field::Phone"}], "backoffice_fields"=>[{"id"=>12483148, "destiny"=>1, "position"=>2, "office_title"=>"Населенный пункт", "for_buyer"=>true, "obligatory"=>true, "active"=>true, "system_name"=>"full_locality_name", "created_at"=>"2020-02-19T16:22:10.372+03:00", "updated_at"=>"2020-02-19T16:22:10.372+03:00", "show_in_result"=>true, "show_in_checkout"=>true, "is_indexed"=>nil, "hide_in_backoffice"=>nil, "handle"=>nil, "title"=>nil, "example"=>nil, "type"=>"Field::Locality"}, {"id"=>12483154, "destiny"=>1, "position"=>5, "office_title"=>"Адрес", "for_buyer"=>true, "obligatory"=>false, "active"=>true, "system_name"=>"address", "created_at"=>"2020-02-19T16:22:10.409+03:00", "updated_at"=>"2020-02-19T16:22:10.409+03:00", "show_in_result"=>true, "show_in_checkout"=>true, "is_indexed"=>nil, "hide_in_backoffice"=>nil, "handle"=>nil, "title"=>nil, "example"=>nil, "type"=>"Field::SystemTextArea"}], "no_delivery"=>false, "kladr_autodetected_address"=>"101000, Россия, г Москва", "country_options"=>[{"code"=>"RU", "title"=>"Россия", "selected"=>false}], "address"=>nil, "country"=>nil, "state"=>"г Москва", "city"=>"Москва", "zip"=>nil, "street"=>nil, "house"=>nil, "flat"=>nil, "entrance"=>nil, "doorphone"=>nil, "floor"=>nil, "kladr_json"=>{"kladr_code"=>"7700000000000", "zip"=>"101000", "kladr_zip"=>nil, "region_zip"=>"101000", "country"=>"RU", "state"=>"Москва", "state_type"=>"г", "area"=>nil, "area_type"=>nil, "city"=>"Москва", "city_type"=>"г", "settlement"=>nil, "settlement_type"=>nil, "result"=>"г Москва", "latitude"=>"55.58422718163563", "longitude"=>"37.385272499999985", "autodetected"=>nil}, "location"=>{"kladr_code"=>"7700000000000", "zip"=>nil, "kladr_zip"=>"101000", "region_zip"=>"101000", "country"=>"RU", "state"=>"Москва", "state_type"=>"г", "area"=>nil, "area_type"=>nil, "city"=>"Москва", "city_type"=>"г", "settlement"=>nil, "settlement_type"=>nil, "address"=>"", "street"=>nil, "street_type"=>nil, "house"=>nil, "flat"=>nil, "is_kladr"=>true, "latitude"=>"55.58422718163563", "longitude"=>"37.385272499999985", "autodetected"=>nil}}, "client"=>{"id"=>nil, "email"=>nil, "name"=>nil, "phone"=>nil, "created_at"=>nil, "updated_at"=>nil, "comment"=>nil, "registered"=>false, "subscribe"=>true, "client_group_id"=>nil, "surname"=>nil, "middlename"=>nil, "bonus_points"=>0, "type"=>"Client::Individual", "correspondent_account"=>nil, "settlement_account"=>nil, "consent_to_personal_data"=>nil, "o_auth_provider"=>nil, "messenger_subscription"=>nil, "contact_name"=>nil, "progressive_discount"=>nil, "group_discount"=>nil, "ip_addr"=>"", "fields_values"=>[]}, "discounts"=>[], "total_price"=>46500.0, "items_price"=>46500.0, "id"=>nil, "key"=>nil, "number"=>nil, "comment"=>nil, "archived"=>false, "delivery_title"=>nil, "delivery_description"=>nil, "delivery_price"=>0.0, "full_delivery_price"=>0.0, "payment_description"=>nil, "payment_title"=>nil, "first_referer"=>nil, "first_current_location"=>"/close_editor?path=%2Fproduct%2Fpanasonic-br-agcf2w%3Flang%3Dru", "first_query"=>nil, "first_source_domain"=>nil, "first_source"=>"", "referer"=>nil, "current_location"=>"/close_editor?path=%2Fproduct%2Fpanasonic-br-agcf2w%3Flang%3Dru", "query"=>nil, "source_domain"=>nil, "source"=>"", "fulfillment_status"=>"new", "custom_status"=>{"permalink"=>"novyy", "title"=>"Новый"}, "delivered_at"=>nil, "accepted_at"=>nil, "created_at"=>nil, "updated_at"=>nil, "financial_status"=>"pending", "delivery_date"=>nil, "delivery_from_hour"=>nil, "delivery_from_minutes"=>nil, "delivery_to_hour"=>nil, "delivery_to_minutes"=>nil, "delivery_time"=>"", "paid_at"=>nil, "delivery_variant_id"=>nil, "payment_gateway_id"=>nil, "margin"=>"0.0", "margin_amount"=>"0.0", "client_transaction_id"=>nil, "currency_code"=>"RUR", "cookies"=>nil, "account_id"=>784184, "manager_comment"=>nil, "locale"=>"ru", "delivery_info"=>{"delivery_variant_id"=>0, "tariff_id"=>nil, "title"=>nil, "description"=>nil, "price"=>nil, "shipping_company"=>nil, "shipping_company_handle"=>nil, "delivery_interval"=>{"min_days"=>nil, "max_days"=>nil, "description"=>""}, "errors"=>[], "warnings"=>[], "outlet"=>{"id"=>nil, "external_id"=>nil, "latitude"=>nil, "longitude"=>nil, "title"=>nil, "description"=>nil, "address"=>nil, "payment_method"=>[], "source_id"=>nil}, "not_available"=>nil}, "responsible_user_id"=>nil, "total_profit"=>"46500.0", "insint"=>{"id"=>nil, "created_at"=>nil, "updated_at"=>nil}}
# content = "this is items title {{discount.items}}" "{% for item in discount.items%}{{item.title}}{%endfor%}"
# "{% for item in discount.items%}{% if item.collections_titlies contains 'Мужская одежда'%}we have 'Мужская одежда'{% endif %}{%endfor%}"
# {% assign muj_coll_array = '' | split: '' %}
# {% for item in discount.items%}{% if item.collections_titlies contains 'Мужская одежда'%}{% assign muj_coll_array = 'true' | slice: forloop.index0 | concat: muj_coll_array %}{% endif %}{%endfor%}
# {% if discount.items.size == muj_coll_array.size %}do_work{% endif %}
# template = Liquid::Template.parse(content)
# html_as_string = template.render!({'discount' => Drops::Discount.new(discount)}, { strict_variables: true })
# check = html_as_string.squish if html_as_string.respond_to?(:squish)


# -- initialise an empty array
# {% assign my_new_array = "" | split: ""%}
# {% for item in my_array %}
# -- apply whatever filtering you'd like
# {% if item.thing == 'something' %}
# -- this is the clever bit
# -- you can use concat (not append) which joins two arrays, so instead of appending 
# -- the item directly, you slice it out which creates an array of 1 and concat the rest
# -- of the array back to it!
# {% assign my_new_array = my_array | slice: forloop.index0 | concat: my_new_array %}
# {% endif %}
# {% endfor %}
# {% assign my_new_array = my_new_array | reverse %}


# datas3 = {"fields_values"=>[], "order_lines"=>[{"colls"=> ["Женская одежда", "Мужская одежда", "Каталог", "Товары на главной"], "id"=>nil, "order_id"=>nil, "sale_price"=>1500.0, "full_sale_price"=>1500.0, "total_price"=>1500.0, "full_total_price"=>1500.0, "discounts_amount"=>0.0, "quantity"=>1, "reserved_quantity"=>nil, "weight"=>"1.0", "dimensions"=>nil, "variant_id"=>297350445, "product_id"=>173896994, "sku"=>"2001", "barcode"=>nil, "title"=>"Демо-товар 2", "unit"=>"pce", "comment"=>nil, "updated_at"=>nil, "created_at"=>nil, "bundle_id"=>nil, "vat"=>-1, "fiscal_product_type"=>1, "requires_marking"=>nil, "marking_codes"=>nil, "accessory_lines"=>[], "external_variant_id"=>nil}, {"colls"=>["Мужская одежда", "Сканеры штрих-кодов"],"id"=>nil, "order_id"=>nil, "sale_price"=>12000.0, "full_sale_price"=>12000.0, "total_price"=>12000.0, "full_total_price"=>12000.0, "discounts_amount"=>0.0, "quantity"=>1, "reserved_quantity"=>nil, "weight"=>nil, "dimensions"=>nil, "variant_id"=>631514614, "product_id"=>375725930, "sku"=>nil, "barcode"=>nil, "title"=>"Куртка", "unit"=>"pce", "comment"=>nil, "updated_at"=>nil, "created_at"=>nil, "bundle_id"=>nil, "vat"=>-1, "fiscal_product_type"=>1, "requires_marking"=>nil, "marking_codes"=>nil, "accessory_lines"=>[], "external_variant_id"=>nil}], "order_changes"=>[], "discount"=>nil, "shipping_address"=>{"id"=>nil, "fields_values"=>[], "name"=>nil, "surname"=>nil, "middlename"=>nil, "phone"=>nil, "formatted_phone"=>nil, "full_name"=>"", "full_locality_name"=>"г Москва", "full_delivery_address"=>"г Москва", "address_for_gis"=>"г Москва", "location_valid"=>true, "recipient_fields"=>[{"id"=>12483149, "destiny"=>2, "position"=>1, "office_title"=>"Имя", "for_buyer"=>true, "obligatory"=>true, "active"=>true, "system_name"=>"name", "created_at"=>"2020-02-19T16:22:10.378+03:00", "updated_at"=>"2020-02-19T16:22:10.378+03:00", "show_in_result"=>true, "show_in_checkout"=>true, "is_indexed"=>nil, "hide_in_backoffice"=>nil, "handle"=>nil, "title"=>nil, "example"=>nil, "type"=>"Field::ObligatoryTextField"}, {"id"=>26940520, "destiny"=>6, "position"=>1, "office_title"=>"Телефон", "for_buyer"=>true, "obligatory"=>true, "active"=>true, "system_name"=>"phone", "created_at"=>"2023-04-21T17:04:34.192+03:00", "updated_at"=>"2023-04-21T17:04:34.192+03:00", "show_in_result"=>true, "show_in_checkout"=>true, "is_indexed"=>nil, "hide_in_backoffice"=>nil, "handle"=>nil, "title"=>nil, "example"=>"", "type"=>"Field::Phone"}], "backoffice_fields"=>[{"id"=>12483148, "destiny"=>1, "position"=>2, "office_title"=>"Населенный пункт", "for_buyer"=>true, "obligatory"=>true, "active"=>true, "system_name"=>"full_locality_name", "created_at"=>"2020-02-19T16:22:10.372+03:00", "updated_at"=>"2020-02-19T16:22:10.372+03:00", "show_in_result"=>true, "show_in_checkout"=>true, "is_indexed"=>nil, "hide_in_backoffice"=>nil, "handle"=>nil, "title"=>nil, "example"=>nil, "type"=>"Field::Locality"}, {"id"=>12483154, "destiny"=>1, "position"=>5, "office_title"=>"Адрес", "for_buyer"=>true, "obligatory"=>false, "active"=>true, "system_name"=>"address", "created_at"=>"2020-02-19T16:22:10.409+03:00", "updated_at"=>"2020-02-19T16:22:10.409+03:00", "show_in_result"=>true, "show_in_checkout"=>true, "is_indexed"=>nil, "hide_in_backoffice"=>nil, "handle"=>nil, "title"=>nil, "example"=>nil, "type"=>"Field::SystemTextArea"}], "no_delivery"=>false, "kladr_autodetected_address"=>"101000, Россия, г Москва", "country_options"=>[{"code"=>"RU", "title"=>"Россия", "selected"=>false}], "address"=>nil, "country"=>nil, "state"=>"г Москва", "city"=>"Москва", "zip"=>nil, "street"=>nil, "house"=>nil, "flat"=>nil, "entrance"=>nil, "doorphone"=>nil, "floor"=>nil, "kladr_json"=>{"kladr_code"=>"7700000000000", "zip"=>"101000", "kladr_zip"=>nil, "region_zip"=>"101000", "country"=>"RU", "state"=>"Москва", "state_type"=>"г", "area"=>nil, "area_type"=>nil, "city"=>"Москва", "city_type"=>"г", "settlement"=>nil, "settlement_type"=>nil, "result"=>"г Москва", "latitude"=>"55.58422718163563", "longitude"=>"37.385272499999985", "autodetected"=>nil}, "location"=>{"kladr_code"=>"7700000000000", "zip"=>nil, "kladr_zip"=>"101000", "region_zip"=>"101000", "country"=>"RU", "state"=>"Москва", "state_type"=>"г", "area"=>nil, "area_type"=>nil, "city"=>"Москва", "city_type"=>"г", "settlement"=>nil, "settlement_type"=>nil, "address"=>"", "street"=>nil, "street_type"=>nil, "house"=>nil, "flat"=>nil, "is_kladr"=>true, "latitude"=>"55.58422718163563", "longitude"=>"37.385272499999985", "autodetected"=>nil}}, "client"=>{"id"=>nil, "email"=>nil, "name"=>nil, "phone"=>nil, "created_at"=>nil, "updated_at"=>nil, "comment"=>nil, "registered"=>false, "subscribe"=>true, "client_group_id"=>nil, "surname"=>nil, "middlename"=>nil, "bonus_points"=>0, "type"=>"Client::Individual", "correspondent_account"=>nil, "settlement_account"=>nil, "consent_to_personal_data"=>nil, "o_auth_provider"=>nil, "messenger_subscription"=>nil, "contact_name"=>nil, "progressive_discount"=>nil, "group_discount"=>nil, "ip_addr"=>"", "fields_values"=>[]}, "discounts"=>[], "total_price"=>13500.0, "items_price"=>13500.0, "id"=>nil, "key"=>nil, "number"=>nil, "comment"=>nil, "archived"=>false, "delivery_title"=>nil, "delivery_description"=>nil, "delivery_price"=>0.0, "full_delivery_price"=>0.0, "payment_description"=>nil, "payment_title"=>nil, "first_referer"=>nil, "first_current_location"=>"/close_editor?path=%2Fproduct%2Fpanasonic-br-agcf2w%3Flang%3Dru", "first_query"=>nil, "first_source_domain"=>nil, "first_source"=>"", "referer"=>nil, "current_location"=>"/close_editor?path=%2Fproduct%2Fpanasonic-br-agcf2w%3Flang%3Dru", "query"=>nil, "source_domain"=>nil, "source"=>"", "fulfillment_status"=>"new", "custom_status"=>{"permalink"=>"novyy", "title"=>"Новый"}, "delivered_at"=>nil, "accepted_at"=>nil, "created_at"=>nil, "updated_at"=>nil, "financial_status"=>"pending", "delivery_date"=>nil, "delivery_from_hour"=>nil, "delivery_from_minutes"=>nil, "delivery_to_hour"=>nil, "delivery_to_minutes"=>nil, "delivery_time"=>"", "paid_at"=>nil, "delivery_variant_id"=>nil, "payment_gateway_id"=>nil, "margin"=>"0.0", "margin_amount"=>"0.0", "client_transaction_id"=>nil, "currency_code"=>"RUR", "cookies"=>nil, "account_id"=>784184, "manager_comment"=>nil, "locale"=>"ru", "delivery_info"=>{"delivery_variant_id"=>0, "tariff_id"=>nil, "title"=>nil, "description"=>nil, "price"=>nil, "shipping_company"=>nil, "shipping_company_handle"=>nil, "delivery_interval"=>{"min_days"=>nil, "max_days"=>nil, "description"=>""}, "errors"=>[], "warnings"=>[], "outlet"=>{"id"=>nil, "external_id"=>nil, "latitude"=>nil, "longitude"=>nil, "title"=>nil, "description"=>nil, "address"=>nil, "payment_method"=>[], "source_id"=>nil}, "not_available"=>nil}, "responsible_user_id"=>nil, "total_profit"=>"13500.0", "insint"=>{"id"=>nil, "created_at"=>nil, "updated_at"=>nil}}
# 
#
# {% assign muj_coll = "" %}
# {% assign test = "" %}
# {% for item in order_lines %}
# {% if item.collections_titlies contains "Мужская одежда" %}
# {% assign muj_coll = muj_coll | append: "," | append: "Мужская одежда" %}
# {% assign test = test | append: "Мужская одежда" %}
# {% endif %}
# {% endfor %}
# {% assign muj_coll_array = muj_coll | remove_first: "," | split: "," %}
# {% if order_lines.size == muj_coll_array.size %}do_work{%else%}false{{order_lines.size}} // {{test}} // {{muj_coll}} // {{muj_coll_array}} // {{muj_coll_array.size}}{% endif %}

# html_as_string = template.render!(context.deep_stringify_keys, { strict_variables: true })
