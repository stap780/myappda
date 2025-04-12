# frozen_string_literal: true

require 'sidekiq-scheduler'

# This worker is to create log files every day
class CreateLogFilesScheduler
  # include Sidekiq::Worker
  include Sidekiq::Job

  def perform
    Rails.application.load_tasks
    Rake::Task['file:create_log_zip_every_day'].invoke
  end
  
end
