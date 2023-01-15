class Event < ApplicationRecord
    has_many :event_actions, dependent: :destroy
    has_many :templates, through: :event_actions
    accepts_nested_attributes_for :event_actions, reject_if: :all_blank    
    has_many :event_order_status_changes
    has_many :order_status_changes , through: :event_order_status_changes

    validates :custom_status, presence: true
    validates :financial_status, presence: true



    FIN_STATUS = [['Не оплачен','pending'],['Оплачен','paid']] #["pending", "paid"]

    def action_title
        action = self.event_actions
        action.present? ? "Канал: "+action.first.channel+". Шаблон: "+action.first.template.title : ''
    end


end
