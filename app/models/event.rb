class Event < ApplicationRecord
  has_many :event_actions, dependent: :destroy
  has_many :templates, through: :event_actions
  accepts_nested_attributes_for :event_actions, reject_if: :all_blank

  validates :casetype, presence: true

  scope :active, -> { where(active: true) }
  scope :restock, -> { where(casetype: 'restock') }
  scope :abandoned_cart, -> { where(casetype: 'abandoned_cart') }
  scope :preorder, -> { where(casetype: 'preorder') }
  scope :favorite, -> { where(casetype: 'favorite') }

  FIN_STATUS = [['Не оплачен','pending'],['Оплачен','paid']].freeze
  TYPES = Mycase::CASETYPE

  def self.ransackable_attributes(auth_object = nil)
    Event.attribute_names
  end

  def action_title
    action = event_actions
    action.present? ? "Канал: #{action.first.channel}. Действие: #{action.first.operation}. Шаблон: #{action.first.template.title}" : ''
  end

  def fin_status
    Event::FIN_STATUS.select{|a| a[1] == financial_status}.flatten.first || ''
  end

  def casetype_value
    Event::TYPES.select{|c| c if c[1] == casetype}.flatten[0]
  end

  def pause_text
    event_actions.present? && event_actions.first.pause ? "Отправка отложена на #{event_actions.first.pause_time} минут." : nil
  end

  def timetable_text
    event_actions.present? && event_actions.first.timetable ? "Выполняется каждые #{event_actions.first.timetable_time.to_i/60} час." : nil
  end

end
