class Event < ApplicationRecord
    has_many :event_actions, dependent: :destroy
    has_many :templates, through: :event_actions
    accepts_nested_attributes_for :event_actions, reject_if: :all_blank    

    validates :casetype, presence: true
    # validates :custom_status, presence: true
    # validates :financial_status, presence: true



    FIN_STATUS = [['Не оплачен','pending'],['Оплачен','paid']].freeze #["pending", "paid"]

    def action_title
        action = self.event_actions
        action.present? ? "Канал: #{action.first.channel}. Дейсвие: #{action.first.operation}. Шаблон: #{action.first.template.title}" : ''
    end

    def fin_status
        Event::FIN_STATUS.select{|a| a[1] == self.financial_status}.flatten.first || ''
    end


end
