# frozen_string_literal: true

# Insint::Order
class Insint::Order < ApplicationService

    def initialize(tenant, datas)
      @tenant = tenant
      @datas = datas
    end

    def call
      Apartment::Tenant.switch(@tenant) do
        client_email = @datas['client']['email'].present? ? @datas['client']['email'] : "#{@datas['client']['id']}@mail.ru"
        client_phone = @datas['client']['phone']
        check_client = client_email.present? ? Client.find_by_email(client_email) : Client.find_by_phone(client_phone)
        client_data = {
          clientid: @datas['client']['id'],
          email: client_email,
          name: @datas['client']['name'],
          phone: client_phone
        }
        check_client.update(client_data.except!(:email)) if check_client.present?
        client = check_client.present? ? check_client : Client.create!(client_data)

        # создаём запись о том что произошло изменение в заказе
        client.order_status_changes.create!(
          insales_order_id: @datas['id'],
          insales_order_number: @datas['number'],
          insales_custom_status_title: @datas['custom_status']['title'],
          insales_financial_status: @datas['financial_status']
        )
        # конец запись о том что произошло изменение в заказе
        #
        mycase_data = {
          client_id: client.id,
          insales_order_id: @datas['id'],
          insales_custom_status_title: @datas['custom_status']['title'],
          insales_financial_status: @datas['financial_status'],
          status: 'new',
          casetype: 'order',
          number: @datas['number']
        }

        mycase = Mycase.where(client_id: client.id, insales_order_id: @datas['id']).first_or_create!(mycase_data)

        puts "mycase => #{mycase.inspect}"
        puts mycase.is_a? Array

        @datas['order_lines'].each do |o_line|
          product = Product.where(insid: o_line['product_id']).first_or_create!
          puts "insint order product => #{product.inspect}"

          variant = Variant.where(insid: o_line['variant_id'], product_id: product.id).first_or_create!

          line = mycase.lines.where(product_id: product.id, variant_id: variant.id)
          line_data = {
            product_id: product.id,
            variant_id: variant.id,
            quantity: o_line['quantity'],
            price: o_line['full_total_price']
          }

          line.present? ? line.first.update!(line_data) : mycase.lines.create!(line_data)
        end

        mycase.do_event_action
        # конец создаём заявку
      end
    end

end
