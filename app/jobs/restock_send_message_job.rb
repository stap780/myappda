class RestockSendMessageJob < ApplicationJob
  queue_as :restock_job
  sidekiq_options retry: 0

  def perform(user, client, events, xml_file)
    RestockService.new(user, client, events, xml_file).do_action
  end
  
end
