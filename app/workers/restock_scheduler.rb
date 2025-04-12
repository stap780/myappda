# frozen_string_literal: true

require 'sidekiq-scheduler'

# This worker is responsible for checking the quantity for restock
class RestockScheduler
  include Sidekiq::Job

  def perform
    Rails.application.load_tasks
    Rake::Task['restock:check_quantity_and_send_client_email'].invoke
  end

end
