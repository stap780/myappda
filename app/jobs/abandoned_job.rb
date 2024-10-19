class AbandonedJob < ApplicationJob
    queue_as :abandoned_job

    def perform(mycase_id, insint, email_data)
        abandoned = Abandoned.new(mycase_id, insint, email_data)
        check_ability = abandoned.check_ability
        abandoned.call if check_ability
    end


end

# test
# abandoned = AbandonedService.new(110,User.find(407).insints.first)
# abandoned.do_action
