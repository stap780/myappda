# AbandonedJob
class AbandonedJob < ApplicationJob
  queue_as :abandoned_job
  def perform(mycase_id, tenant, email_data)
    Abandoned.call(mycase_id, tenant, email_data)
  end
end

# test
# abandoned = AbandonedService.new(110,User.find(407).insints.first)
# abandoned.do_action