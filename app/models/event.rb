class Event < ApplicationRecord
    has_many :event_actions, dependent: :destroy
    has_many :templates, through: :event_actions
    accepts_nested_attributes_for :event_actions, reject_if: :all_blank    

    validates :casetype, presence: true
    # validates :custom_status, presence: true
    # validates :financial_status, presence: true
    # after_commit :restock_job, on: [:create, :update]

    FIN_STATUS = [['Не оплачен','pending'],['Оплачен','paid']].freeze #["pending", "paid"]



    def action_title
        action = self.event_actions
        action.present? ? "Канал: #{action.first.channel}. Дейсвие: #{action.first.operation}. Шаблон: #{action.first.template.title}" : ''
    end

    def fin_status
        Event::FIN_STATUS.select{|a| a[1] == self.financial_status}.flatten.first || ''
    end

    def casetype_value
        Case::CASETYPE.select{|c| c if c[1] == self.casetype}.flatten[0]
    end

    def pause_text
        self.event_actions.present? && self.event_actions.first.pause ? "Отправка отложена на #{self.event_actions.first.pause_time} минут." : nil
    end

    def timetable_text
        self.event_actions.present? && self.event_actions.first.timetable ? "Выполняется каждые #{self.event_actions.first.timetable_time.to_i/60} час." : nil
    end


    # def restock_job
    #     user = User.find_by_subdomain(Apartment::Tenant.current)
    #     timetable_time = self.timetable_time
    #     if self.casetype == 'restock'
    #       RestockJob.set(wait: wait.to_i.minutes).perform_later(self.insales_order_id, operation, insint)
    #     end
    # end

end
