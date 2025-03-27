# Mycase < ApplicationRecord
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

  after_create_commit do
    broadcast_prepend_to [Apartment::Tenant.current, :mycases],target: "#{Apartment::Tenant.current}_mycases",partial: 'mycases/mycase',locals: {mycase: self}
  end
  after_update_commit do
    broadcast_replace_to [Apartment::Tenant.current, :mycases], target: dom_id(self, Apartment::Tenant.current),partial: 'mycases/mycase',locals: {mycase: self}
  end
  after_destroy_commit do
    broadcast_remove_to [Apartment::Tenant.current, :mycases], target: dom_id(self, Apartment::Tenant.current)
  end

  scope :orders, -> { where(casetype: 'order') }
  scope :restocks, -> { where(casetype: 'restock') }
  scope :abandoned_carts, -> { where(casetype: 'abandoned_cart') }
  scope :preorders, -> { where(casetype: 'preorder') }
  scope :status_new, -> { where(status: 'new') }

  CASETYPE = [
    ['Заказ (insales)', 'order'],
    ['Сообщить о поступлении', 'restock'],
    ['Брошенная корзина', 'abandoned_cart'],
    ['Предзаказ', 'preorder']
  ].freeze
  STATUS = [
    ['Новый', 'new'],
    ['В работе', 'take'],
    ['Завершили', 'finish']
  ].freeze

  def self.ransackable_attributes(auth_object = nil)
    attribute_names
  end

  def self.ransackable_associations(auth_object = nil)
    %w[client lines products variants]
  end

  def casetype_value
    return '' unless casetype.present?

    Mycase::CASETYPE.select { |c| c if c[1] == casetype }.flatten[0]
  end

  def add_restock
    return unless casetype == 'restock'

    lines.each do |line|
      restocks.create!(product_id: line.product.id, variant_id: line.variant.id, client_id: client.id)
    end
  end

  def add_preorder
    return unless casetype == 'preorder'

    lines.each do |line|
      preorders.create!(product_id: line.product.id, variant_id: line.variant.id, client_id: client.id)
    end
  end

  def add_abandoned_cart
    return unless casetype == 'abandoned_cart'

    lines.each do |line|
      data = { product_id: line.product.id, variant_id: line.variant.id, client_id: client.id, mycase_id: id }
      abandoned = AbandonedCart.where(data).first
      AbandonedCart.create!(data) unless abandoned.present?
    end
  end

  def self.api_insales_statuses
    return [] unless Insint.work? && ApiInsales.new(Insint.current).account

    ApiInsales.new(Insint.current).statuses
  end

  # NOTICE for 'order' & 'abandoned_cart' & 'preorder'
  def do_event_action
    user = User.find_by_subdomain(Apartment::Tenant.current)
    casetypes = %w[order abandoned_cart preorder]
    return unless casetypes.include?(casetype)

    puts "########## Case do_event_action start - #{casetype}"
    events = Event.active.where(casetype: casetype)
    if events.size.positive?
      puts "case do_event_action events.size > 0 and count = #{events.size}"
      events.each do |event|
        EventActionService.new(user, event, self).do_action
      end
    end
    puts '########## Case do_event_action finish'
  end

  def self.restock_update_cases(client)
    client.mycases.where(casetype: 'restock').each do |mycase|
      lines_state = mycase.lines.map { |line| line.variant.restocks.first.status }
      # puts "lines_state.uniq => "+lines_state.uniq
      mycase.update(status: 'finish') if lines_state.uniq.join == 'send'
    end
  end

  # NOTICE not find where use this method
  # def self.preorder_update_cases(client)
  #   client.mycases.where(casetype: 'preorder').each do |mycase|
  #     lines_state = mycase.lines.map { |line| line.variant.preorders.first.status }
  #     # puts "lines_state.uniq => "+lines_state.uniq
  #     mycase.update(status: 'finish') if lines_state.uniq.join == 'send'
  #   end
  # end

  def client_data
    client ? "#{client.fio}<br>#{client.email} #{client.phone}".html_safe : ''
  end

  def status_title
    return '' unless status.present?

    Mycase::STATUS.map { |a| a[0] if a[1] == status }.compact.join
  end

  def lines_sum
    return '' unless lines.present?

    sum = lines.map { |item| item.quantity.to_i * item.price.to_i }
    sum.sum
  end

  def delete_lines_and_relation_abandoned
    lines.each do |line|
      data = { product_id: line.product.id, variant_id: line.variant.id, client_id: client.id, mycase_id: id }
      abandoned = AbandonedCart.where(data).first
      abandoned.destroy if abandoned.present?
    end
    lines.delete_all
  end

end
