#  encoding : utf-8
namespace :favorite_setup do
  desc "favorite_setup rework"

# задача устанавливает статус и тариф для старых пользователей после смены логики работы . только один раз запускать
  task set_status_and_set_payplan_for_old_users: :environment do
    puts "start set_status_and_set_payplan_for_old_users - время москва - #{Time.zone.now}"
    # rake file:cut_file QUEUE="*" --trace > /var/www/myappda/shared/log/cut_file.log 2>&1

    Insint.all.order(:id).each do | insint |
      tenant = insint.user.subdomain
      payplan = Payplan.where(service_handle: "favorite").last
      payplan_id = payplan.id
      Apartment::Tenant.switch(tenant) do
        puts tenant.to_s
        # Создаём сервис - автоматом бесплатный
        fs = FavoriteSetup.create(title: FavoriteSetup::TITLE, handle: FavoriteSetup::HANDLE )
        # на update срабатывают колбэки - создаётся счет с бесплатным тарифом
        fs.update(description: FavoriteSetup::DESCRIPTION)
        # меняем в сервисе тарифный план и включаем сервис и срабатывает колбэк создания счета но с платным тарифом
        fs.update(status: true, payplan_id: payplan_id)

        invoice = Invoice.where(status: "Не оплачен").where.not(sum: 0).last
        invoice.update(paymenttype: "paypal") if invoice #срабатывает колбэк создания платежа
      end

      user = insint.user
      payment = Payment.where(user_id: user.id, payplan_id: payplan_id, status: 'Не оплачен', paymenttype: "paypal")
      payment.update(status: "Оплачен", paymentdate: Time.now) if payment #срабатывает колбэк обновления платежа
    end

    puts "finish set_status_and_set_payplan_for_old_users - время москва - #{Time.zone.now}"
  end

end
