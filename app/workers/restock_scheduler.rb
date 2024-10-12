require "sidekiq-scheduler"

class RestockScheduler
  include Sidekiq::Worker

  def perform
    Rails.application.load_tasks
    Rake::Task["restock:check_quantity_and_send_client_email"].invoke
  end
end
