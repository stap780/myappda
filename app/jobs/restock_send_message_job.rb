class RestockSendMessageJob < ApplicationJob
  queue_as :restock_job
  sidekiq_options retry: 0

  def perform(tenant, client_id, xml_file)
    Apartment::Tenant.switch(tenant) do
      client = Client.find(client_id)
      Restock::SendMessage.call(tenant, client, xml_file)
    end
  end
end
