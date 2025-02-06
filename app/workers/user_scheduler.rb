require 'sidekiq-scheduler'

class UserScheduler
  # include Sidekiq::Worker
  include Sidekiq::Job

  def perform
    User.service_end_email
  end

end