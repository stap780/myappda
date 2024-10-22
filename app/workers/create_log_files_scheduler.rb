require "sidekiq-scheduler"

class CreateLogFilesScheduler
  # include Sidekiq::Worker
  include Sidekiq::Job

  def perform
    Rails.application.load_tasks
    Rake::Task["file:copy_production_log_every_day"].invoke
  end
end
