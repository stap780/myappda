require 'sidekiq-scheduler'

# MessageServiceScheduler
class MessageServiceScheduler
  # include Sidekiq::Worker
  include Sidekiq::Job

  def perform
    User.order(:id).each do |user|
      Apartment::Tenant.switch(user.subdomain) do
        MessageSetup.set_service_status
      end
    end
  end

end