# frozen_string_literal: true

require 'sidekiq-scheduler'

# This worker run to inform users about the end of their service
class UserScheduler
  include Sidekiq::Job

  def perform
    User.service_end_email
  end

end