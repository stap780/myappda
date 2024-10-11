class InsintOrderJob < ApplicationJob
  queue_as :insint_job
  sidekiq_options retry: 0

  def perform(tenant, params)
    Insint::Order.call(tenant, params)
  end
end
