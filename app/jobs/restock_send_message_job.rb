# frozen_string_literal: true

# job for send restock message
class RestockSendMessageJob < ApplicationJob
  queue_as :restock_job
  sidekiq_options retry: 0

  def perform(tenant, options)
    Apartment::Tenant.switch(tenant) do
      client = Client.find(options[:client_id])
      Restock::SendMessage.call(tenant, client)
    end
  end

end
