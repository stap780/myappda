class Event < ApplicationRecord
    has_many :event_actions
    accepts_nested_attributes_for :event_actions, reject_if: :all_blank    
    has_many :event_order_status_changes
    has_many :order_status_changes , through: :event_order_status_changes
  


    FIN_STATUS = ["pending", "paid"]

    def action_title
        action = self.event_actions
        action.present? ? "Канал: "+action.first.channel+". Шаблон: "+action.first.template.title : ''
    end


end
