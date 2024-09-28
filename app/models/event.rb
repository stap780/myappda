class Event < ApplicationRecord
    has_many :event_actions, dependent: :destroy
    has_many :templates, through: :event_actions
    accepts_nested_attributes_for :event_actions, reject_if: :all_blank    

    validates :casetype, presence: true

    scope :active, -> { where(active: true) }

    FIN_STATUS = [['Не оплачен','pending'],['Оплачен','paid']].freeze #["pending", "paid"]
    TYPES = Mycase::CASETYPE #+ [['Избранное','favorite']]

    def self.ransackable_attributes(auth_object = nil)
        Event.attribute_names
    end

    def action_title
        action = self.event_actions
        action.present? ? "Канал: #{action.first.channel}. Действие: #{action.first.operation}. Шаблон: #{action.first.template.title}" : ''
    end

    def fin_status
        Event::FIN_STATUS.select{|a| a[1] == self.financial_status}.flatten.first || ''
    end

    def casetype_value
        Event::TYPES.select{|c| c if c[1] == self.casetype}.flatten[0]
    end

    def pause_text
        self.event_actions.present? && self.event_actions.first.pause ? "Отправка отложена на #{self.event_actions.first.pause_time} минут." : nil
    end

    def timetable_text
        self.event_actions.present? && self.event_actions.first.timetable ? "Выполняется каждые #{self.event_actions.first.timetable_time.to_i/60} час." : nil
    end

end
