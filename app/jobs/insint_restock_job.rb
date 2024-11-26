class InsintRestockJob < ApplicationJob
  queue_as :insint_job
  sidekiq_options retry: 0

  def perform(tenant, datas)
    Insint::Restock.call(tenant, datas)
  end

end