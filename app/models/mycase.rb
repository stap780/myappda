class Mycase < ApplicationRecord
  belongs_to :client
  has_many :lines
  accepts_nested_attributes_for :lines, allow_destroy: true
  has_many :products, through: :lines
  has_many :variants, through: :lines
  has_many :restocks, dependent: :destroy
  has_many :preorders, dependent: :destroy
  has_many :abandoned_carts, dependent: :destroy

  include ActionView::RecordIdentifier

  before_save :normalize_data_white_space
  # after_create :add_restock
  # after_commit :do_event_action, on: :create # for 'order' & 'abandoned_cart' & 'preorder' # отключил, так как работало некоректно и добавил это действие в конце каждого запроса в insint

  after_create_commit do
    broadcast_prepend_to [Apartment::Tenant.current, :mycases], target: "#{Apartment::Tenant.current}_mycases",
      partial: "mycases/mycase",
      locals: {mycase: self}
  end
  after_update_commit do
    broadcast_replace_to [Apartment::Tenant.current, :mycases], target: dom_id(self, Apartment::Tenant.current),
      partial: "mycases/mycase",
      locals: {mycase: self}
  end
  after_destroy_commit do
    broadcast_remove_to [Apartment::Tenant.current, :mycases], target: dom_id(self, Apartment::Tenant.current)
  end

  scope :orders, -> { where(casetype: "order") }
  scope :restocks, -> { where(casetype: "restock") }
  scope :abandoned_carts, -> { where(casetype: "abandoned_cart") }
  scope :preorders, -> { where(casetype: "preorder") }
  scope :status_new, -> { where(status: "new") }

  CASETYPE = [["Заказ (insales)", "order"], ["Сообщить о поступлении", "restock"], ["Брошенная корзина", "abandoned_cart"], ["Предзаказ", "preorder"]].freeze
  STATUS = [["Новый", "new"], ["В работе", "take"], ["Завершили", "finish"]].freeze

  def self.ransackable_attributes(auth_object = nil)
    Mycase.attribute_names
  end

  def self.ransackable_associations(auth_object = nil)
    ["client", "lines", "products", "variants"]
  end

  def casetype_value
    return "" unless casetype.present?
    Mycase::CASETYPE.select { |c| c if c[1] == casetype }.flatten[0]
  end

  def add_restock
    if casetype == "restock"
      puts "Case add_restock start"
      lines.each do |line|
        self.restocks.create!(product_id: line.product.id, variant_id: line.variant.id, client_id: client.id)
      end
      puts "Case add_restock finish"
    end
  end

  def add_preorder
    if casetype == "preorder"
      puts "Case add_preorder start"
      lines.each do |line|
        self.reorders.create!(product_id: line.product.id, variant_id: line.variant.id, client_id: client.id)
      end
      puts "Case add_preorder finish"
    end
  end

  def add_abandoned_cart
    if casetype == "abandoned_cart"
      puts "Case add_abandoned_cart start"
      lines.each do |line|
        self.abandoned_carts.create!(product_id: line.product.id, variant_id: line.variant.id, client_id: client.id)
      end
      puts "Case add_abandoned_cart finish"
    end
  end

  # for 'order' & 'abandoned_cart' & 'preorder'
  def do_event_action
    user = User.find_by_subdomain(Apartment::Tenant.current)

    if casetype == "order" || casetype == "abandoned_cart" || casetype == "preorder"
      puts "########## Case do_event_action start - #{casetype}"
      events = Event.active.where(casetype: casetype)
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
    client.mycases.where(casetype: "restock").each do |mycase|
      lines_state = mycase.lines.map { |line| line.variant.restocks.first.status }
      # puts "lines_state.uniq => "+lines_state.uniq
      (lines_state.uniq.join == "send") ? mycase.update(status: "finish") : nil
    end
  end

  def self.preorder_update_cases(client)
    client.mycases.where(casetype: "preorder").each do |mycase|
      lines_state = mycase.lines.map { |line| line.variant.preorders.first.status }
      # puts "lines_state.uniq => "+lines_state.uniq
      (lines_state.uniq == "send") ? mycase.update(status: "finish") : nil
    end
  end

  def client_data
    client ? "#{client.fio}<br>#{client.email}<br>#{client.phone}".html_safe : ""
  end

  def status_title
    return "" unless status.present?
    Mycase::STATUS.map { |a| a[0] if a[1] == status }.compact.join
  end

  def lines_sum
    return "" unless lines.present?
    sum = lines.map { |item| item.quantity.to_i * item.price.to_i }
    sum.sum
  end

  private

  def normalize_data_white_space
    attributes.each do |key, value|
      self[key] = value.squish if value.respond_to?(:squish)
    end
  end
end
