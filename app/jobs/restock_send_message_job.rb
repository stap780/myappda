# frozen_string_literal: true

# job for send restock message
class RestockSendMessageJob < ApplicationJob
  queue_as :restock_job
  sidekiq_options retry: 0

  def perform(tenant, client)
    Restock::SendMessage.call(tenant, client)
  end

end
