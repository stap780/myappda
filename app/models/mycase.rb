class Mycase < ApplicationRecord
  belongs_to :client
  has_many :lines
  accepts_nested_attributes_for :lines, allow_destroy: true
  has_many :products, through: :lines
  has_many :variants, through: :lines

  include ActionView::RecordIdentifier

  before_save :normalize_data_white_space
  # after_create :add_restock
  # after_commit :do_event_action, on: :create # for 'order' & 'abandoned_cart' & 'preorder' # отключил, так как работало некоректно и добавил это действие в конце каждого запроса в insint

  after_create_commit do
    broadcast_prepend_to [Apartment::Tenant.current, :mycases], target: "#{Apartment::Tenant.current}_mycases",
    partial: "mycases/mycase", 
    locals: { mycase: self }
  end
  after_update_commit do
    broadcast_replace_to [Apartment::Tenant.current, :mycases], target: dom_id(self, Apartment::Tenant.current),
    partial: "mycases/mycase", 
    locals: { mycase: self }
  end
  after_destroy_commit do
    broadcast_remove_to [Apartment::Tenant.current, :mycases], target: dom_id(self, Apartment::Tenant.current)
  end


  CASETYPE = [['Заказ (insales)','order'],['Сообщить о поступлении','restock'],['Брошенная корзина','abandoned_cart'],['Предзаказ','preorder']].freeze
  STATUS = [['Новый','new'],['В работе','take'],['Завершили','finish']].freeze
  
  def self.ransackable_attributes(auth_object = nil)
    Mycase.attribute_names
  end

  def self.ransackable_associations(auth_object = nil)
    ["client", "lines", "products", "variants"]
  end

  def casetype_value
    return '' unless casetype.present?
    Mycase::CASETYPE.select{|c| c[0] if c[1] == self.casetype}.compact.join(' ')
  end

  def add_restock
    if self.casetype == 'restock'
      puts "Case add_restock start"
      self.lines.each do |line|
        Restock.create!(product_id: line.product.id, variant_id: line.variant.id, client_id: self.client.id)
      end
      puts "Case add_restock finish"
    end
  end

  def add_preorder
    if self.casetype == 'preorder'
      puts "Case add_preorder start"
      self.lines.each do |line|
        Preorder.create!(product_id: line.product.id, variant_id: line.variant.id, client_id: self.client.id)
      end
      puts "Case add_preorder finish"
    end
  end

  # for 'order' & 'abandoned_cart' & 'preorder'
  def do_event_action
    user = User.find_by_subdomain(Apartment::Tenant.current)

    if self.casetype == 'order' || self.casetype == 'abandoned_cart' || self.casetype == 'preorder'
      puts "########## Case do_event_action start - #{self.casetype}"
      events = Event.active.where(casetype: self.casetype)
      if events.size > 0
        puts "case do_event_action events.size > 0 and count = #{events.size}"
        events.each do |event|
          EventActionService.new(user, event, self).do_action
        end
      end
      puts "########## Case do_event_action finish"
    end
  end

  def self.restock_update_cases(client)
    client.mycases.where(casetype: 'restock').each do |mycase|
      lines_state = mycase.lines.map{|line| line.variant.restocks.first.status}
      # puts "lines_state.uniq => "+lines_state.uniq
      lines_state.uniq.join == 'send' ? mycase.update(status: 'finish') : nil
    end
  end

  def self.preorder_update_cases(client)
    client.mycases.where(casetype: 'preorder').each do |mycase|
      lines_state = mycase.lines.map{|line| line.variant.preorders.first.status}
      # puts "lines_state.uniq => "+lines_state.uniq
      lines_state.uniq == 'send' ? mycase.update(status: 'finish') : nil
    end
  end

  def client_data
    self.client ? "#{self.client.fio.to_s}<br>#{self.client.email.to_s}<br>#{self.client.phone.to_s}".html_safe : ''
  end

  def status_title
    return '' unless status.present?
    Mycase::STATUS.map{|a| a[0] if  a[1] == self.status}.compact.join
  end

  def lines_sum
    return '' unless self.lines.present?
    sum = self.lines.map{|item| item.quantity.to_i*item.price.to_i }
    sum.sum
  end

  private

  def normalize_data_white_space
    self.attributes.each do |key, value|
      self[key] = value.squish if value.respond_to?("squish")
    end
  end


end
