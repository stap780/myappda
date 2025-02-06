require 'sidekiq-scheduler'

class MessageServiceScheduler
  # include Sidekiq::Worker
  include Sidekiq::Job

  def perform
    MessageSetup.set_service_status
  end

end