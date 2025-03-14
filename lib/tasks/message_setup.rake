#  encoding : utf-8
namespace :message_setup do
  desc 'message_setup'

  # NOTICE отправляем письмо клиенту если check_ability не проходит
  task message_service_not_work_email: :environment do
    puts "start favorite_service_not_work_email - время москва - #{Time.zone.now}"

    User.all.order(:id).each do | user |
      tenant = user.subdomain
      Apartment::Tenant.switch(tenant) do
        check_ability_result = FavoriteSetup.check_ability
        if check_ability_result == false
        UserMailer.with(user: user).message_setup_service_email.deliver_now
        puts "send email to tenant - "+tenant.to_s
        end
      end
    end

    puts "finish favorite_service_not_work_email - время москва - #{Time.zone.now}"
  end


end