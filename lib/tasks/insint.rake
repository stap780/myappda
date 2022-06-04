#  encoding : utf-8
namespace :insint do
  desc "recreate_insint_as_tenant_case"

# писал эту задачу когда думал менять алгоритм работы с инсалес и планировал поместить работу с интеграцие внутрь апартмента.
# но не получилось отправлять и получать запросы из вне внутрь апартмента по json
  task recreate_insint_as_tenant_case: :environment do
    puts "start recreate_insint_as_tenant_case - время москва - #{Time.zone.now}"
    # rake file:cut_file QUEUE="*" --trace > /var/www/myappda/shared/log/cut_file.log 2>&1

    Insint.all.order(:id).each do | insint |
      tenant = insint.user.subdomain
      Apartment::Tenant.switch(tenant) do
        Insint.create(subdomen: insint.subdomen, password: insint.password, insalesid: insint.insalesid, user_id: insint.user_id, inskey: insint.inskey, status: insint.status)
      end
    end

    puts "finish recreate_insint_as_tenant_case - время москва - #{Time.zone.now}"
  end

end
