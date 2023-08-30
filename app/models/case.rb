class Case < ApplicationRecord
  belongs_to :client
  has_many :lines
  accepts_nested_attributes_for :lines, allow_destroy: true #,reject_if: proc { |attributes| attributes['weight'].blank? }
  has_many :products, through: :lines
  has_many :variants, through: :lines

  before_save :normalize_data_white_space
  # after_create :add_restock
  after_commit :do_event_action, on: :create # for 'order' & 'abandoned_cart' & 'preorder'

  CASETYPE = [['Заказ','order'],['Сообщить о поступлении','restock'],['Брошенная корзина','abandoned_cart'],['Предзаказ','preorder']].freeze
  STATUS = [['Новый','new'],['В работе','take'],['Завершили','finish']].freeze

  def casetype_value
    Case::CASETYPE.select{|c| c if c[1] == self.casetype}.flatten[0]
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
    if self.casetype == 'order' || self.casetype == 'abandoned_cart' || self.casetype == 'preorder'
      puts "Case do_event_action start"
      events = Event.where(casetype: self.casetype)
      if events.present?
        puts "case do_event_action"
        user = User.find_by_subdomain(Apartment::Tenant.current)
        events.each do |event|
          Services::EventAction.do_action(user, event, self)
        end
      end
      puts "Case do_event_action finish"
    end
  end

  def self.restock_update_cases(client)
    client.cases.where(casetype: 'restock').each do |mycase|
      lines_state = mycase.lines.map{|line| line.variant.restocks.first.status}
      # puts "lines_state.uniq => "+lines_state.uniq
      lines_state.uniq == 'send' ? mycase.update(status: 'finish') : nil
    end
  end

  def self.preorder_update_cases(client)
    client.cases.where(casetype: 'preorder').each do |mycase|
      lines_state = mycase.lines.map{|line| line.variant.preorders.first.status}
      # puts "lines_state.uniq => "+lines_state.uniq
      lines_state.uniq == 'send' ? mycase.update(status: 'finish') : nil
    end
  end

  def client_data
    self.client ? self.client.fio.to_s+" - "+self.client.email.to_s+" - "+self.client.phone.to_s : ''
  end

  private

  def normalize_data_white_space
    self.attributes.each do |key, value|
      self[key] = value.squish if value.respond_to?("squish")
    end
  end


end
