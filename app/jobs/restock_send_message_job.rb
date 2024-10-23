class RestockSendMessageJob < ApplicationJob
  queue_as :restock_job
  sidekiq_options retry: 0

  def perform(tenant, client, xml_file)
    Restock::SendMessage.call(tenant, client, xml_file)
  end
  
end
