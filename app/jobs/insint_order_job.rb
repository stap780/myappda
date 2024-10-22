class InsintOrderJob < ApplicationJob
  queue_as :insint_job
  sidekiq_options retry: 0

  def perform(tenant, datas)
    Insint::Order.call(tenant, datas)
  end
  
end
