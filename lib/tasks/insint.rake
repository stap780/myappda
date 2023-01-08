#  encoding : utf-8
namespace :insint do
  desc "insint work"

  task update_insales_account_id_to_insint: :environment do
    puts "start update_insales_id_to_insint - время москва - #{Time.zone.now}"

    User.all.order(:id).each do | user |
        insint = user.insints.first
        if insint.present?
          service = Services::InsalesApi.new(insint)
          if service.account.present?
            # puts user.id.to_s
            insales_account_id = service.account.id
            insint.update(insales_account_id: insales_account_id)
          end
        end
    end

    puts "finish update_insales_id_to_insint - время москва - #{Time.zone.now}"
end

# писал эту задачу когда думал менять алгоритм работы с инсалес и планировал поместить работу с интеграцие внутрь апартмента.
# но не получилось отправлять и получать запросы из вне внутрь апартмента по json
  # task recreate_insint_as_tenant_case: :environment do
  #   puts "start recreate_insint_as_tenant_case - время москва - #{Time.zone.now}"
  #   # rake file:cut_file QUEUE="*" --trace > /var/www/myappda/shared/log/cut_file.log 2>&1

  #   Insint.all.order(:id).each do | insint |
  #     tenant = insint.user.subdomain
  #     Apartment::Tenant.switch(tenant) do
  #       Insint.create(subdomen: insint.subdomen, password: insint.password, insalesid: insint.insalesid, user_id: insint.user_id, inskey: insint.inskey, status: insint.status)
  #     end
  #   end

  #   puts "finish recreate_insint_as_tenant_case - время москва - #{Time.zone.now}"
  # end

end
