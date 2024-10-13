class Product < ApplicationRecord
  has_many :lines
  has_many :mycases, through: :lines
  has_many :favorites, dependent: :destroy
  # has_many :clients, through: :favorites
  has_many :variants, dependent: :destroy
  accepts_nested_attributes_for :variants, allow_destroy: true
  has_many :restocks, dependent: :destroy
  has_many :preorders, dependent: :destroy
  after_commit :get_ins_data, on: [:create]

  validates :insid, presence: true
  validates :insid, uniqueness: true

  def self.ransackable_attributes(auth_object = nil)
    Product.attribute_names
  end

  def self.ransackable_associations(auth_object = nil)
    ["clients", "favorites", "lines", "mycases", "preorders", "restocks", "variants"]
  end

  # def self.get_image(insid)
  #   puts "get_image"
  #   current_subdomain = Apartment::Tenant.current
  #   Apartment::Tenant.switch!(current_subdomain)
  #   user = User.find_by_subdomain(current_subdomain)
  #   insint = user.insints.first
  #   if insint.inskey.present?
  #     uri = "http://"+"#{insint.inskey}"+":"+"#{insint.password}"+"@"+"#{insint.subdomen}"+"/admin/products/#{insid}/images.json"
  #   else
  #     uri = "http://k-comment:"+"#{insint.password}"+"@"+"#{insint.subdomen}"+"/admin/products/#{insid}/images.json"
  #   end
  #   RestClient.get( uri, :content_type => :json, :accept => :json) { |response, request, result, &block|
  #           case response.code
  #           when 200
  #             data = JSON.parse(response)
  #             link = data.present? ? data[0]['compact_url'] : ''
  #           when 404
  #             puts "error 404 get_image"
  #             link = ''
  #           when 403
  #             puts "error 403 get_image"
  #             link = ''
  #           else
  #             response.return!(&block)
  #           end
  #           }
  # end

  # def self.get_image_api(insid)
  #   puts "get_image"
  #   current_subdomain = Apartment::Tenant.current
  #   Apartment::Tenant.switch!(current_subdomain)
  #   user = User.find_by_subdomain(current_subdomain)
  #   insint = user.insints.first
  #   if insint.inskey.present?
  #     uri = "http://"+"#{insint.inskey}"+":"+"#{insint.password}"+"@"+"#{insint.subdomen}"+"/admin/products/#{insid}/images.json"
  #   else
  #     uri = "http://k-comment:"+"#{insint.password}"+"@"+"#{insint.subdomen}"+"/admin/products/#{insid}/images.json"
  #   end
  #   uri
  # end

  # def get_ins_product_data
  #   puts "get_ins_product_data"
  #   # puts Apartment::Tenant.current
  #   current_subdomain = Apartment::Tenant.current
  #   user = User.find_by_subdomain(current_subdomain)
  #   puts "user.id - "+user.id.to_s
  #   insint = user.insints.first
  #   if insint.present? && insint.status
  #     ins_product_id = self.insid.to_s
  #     insint_inskey = insint.inskey.present? ? insint.inskey : "k-comment"
  #     uri = "http://#{insint_inskey}:#{insint.password}@#{insint.subdomen}/admin/products/#{ins_product_id}.json"
  #     puts "uri get_ins_product_data - "+uri.to_s
  #     RestClient.get( uri, :content_type => :json, :accept => :json) { |response, request, result, &block|
  #             case response.code
  #             when 200
  #               data = JSON.parse(response)
  #               product_data = {
  #                 title: data['title'],
  #                 price: data['variants'][0]['base_price']
  #               }
  #               self.update!(product_data)
  #             when 404
  #               puts "error 404 get_ins_product_data"
  #             when 403
  #               puts "error 403 get_ins_product_data"
  #             else
  #               response.return!(&block)
  #             end
  #             }
  #   end
  # end

  def get_ins_data
    puts "start product get_ins_data"
    current_subdomain = Apartment::Tenant.current
    user = User.find_by_subdomain(current_subdomain)
    service = ApiInsales.new(user.insints.first)
    if service.work?
      product = service.get_product_data(insid)
      product_data = {
        title: product.title,
        image_link: product.images.present? ? product.images.first.original_url : ""
      }
      update!(product_data)
    end
    puts "finish product get_ins_data"
  end

  # def do_restock_event_action
  #   events = Event.active.where(casetype: 'restock')
  #   if events.present?
  #     puts "do_restock_event_action"
  #     user = User.find_by_subdomain(Apartment::Tenant.current)
  #     events.each do |event|
  #       if event.casetype == 'restock'
  #         action = event.event_actions.first
  #         channel = action.channel
  #         operation = action.operation
  #         pause = action.pause
  #         pause_time = action.pause_time
  #         timetable = action.timetable
  #         receiver = self.client.email if action.template.receiver == 'client'
  #         receiver = user.email if action.template.receiver == 'manager'
  #         insint = user.insints.first
  #         service = ApiInsales.new(insint)
  #         order = service.order(self.insales_order_id)
  #         client = service.client(order.client.id)

  #         subject_template = Liquid::Template.parse(action.template.subject)
  #         content_template = Liquid::Template.parse(action.template.content)
  #         order_drop = Drops::InsalesOrder.new(order)
  #         client_drop = Drops::InsalesClient.new(client)

  #         subject = subject_template.render('order' => order_drop, 'client' => client_drop)
  #         content = content_template.render('order' => order_drop, 'client' => client_drop)

  #         email_data = {
  #           user: user,
  #           subject: subject,
  #           content: content,
  #           receiver: receiver
  #         }
  #         # puts "email_data => "+email_data.to_s

  #         wait = pause == true && pause_time.present? ? pause_time : 1
  #         if channel == 'email'
  #           EventMailer.with(email_data).send_action_email.deliver_later(wait: wait.to_i.minutes)
  #         end
  #         if channel == 'insales_api' && operation == 'cancel_order'
  #           CancelOrderJob.set(wait: wait.to_i.minutes).perform_later(self.insales_order_id, operation, insint)
  #         end
  #       end
  #     end
  #   end
  # end
end
