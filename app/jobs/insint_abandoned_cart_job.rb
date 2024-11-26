class InsintAbandonedCartJob < ApplicationJob
  queue_as :insint_job
  sidekiq_options retry: 0

  def perform(tenant, datas)
    Insint::AbandonedCart.call(tenant, datas)
  end

end