#  encoding : utf-8

namespace :restock do
  desc 'restock schedule update'

  task check_quantity_and_send_client_email: :environment do
    logger = Logger.new(Rails.root.join('log', 'restock.log'))
    logger.info "###### start check_product_qt - время москва - #{Time.zone.now}"
    tenants = User.order(:id).pluck(:subdomain)
    logger.info "=======всего tenants - #{tenants.count}"
    tenants.each do |tenant|
      Apartment::Tenant.switch(tenant) do
        logger.info '======='
        ms = MessageSetup.first
        client_ids = Mycase.restocks.status_new.group(:client_id).count.map { |id, _count| id }
        logger.info "status #{ms&.status} // product_xml #{!ms&.product_xml.blank?} // client_ids #{client_ids.present?}"
        if ms&.status && !ms&.product_xml.blank? && client_ids.present?
          xml_file = Restock::GetFile.call(ms.product_xml)
          if xml_file.present?
            Restock::SetStatusForInform.call(tenant, xml_file)
            client_ids.each do |client_id|
              client = Client.find(client_id)
              if client.restocks.for_inform.present?
                RestockSendMessageJob.perform_later(tenant, {client_id: client_id})
                logger.info "**** создали задание #{client_id} ****"
              end
            end
          end
          logger.info "**** запустили #{tenant} ****"
        else
          logger.info "не запустили #{tenant}"
        end
      end
    end

    logger.info "###### finish check_product_qt - время москва - #{Time.zone.now}"
  end

end

# testing
# tenant = 'teletri'
# Apartment::Tenant.switch!(tenant)
# user = User.find_by_subdomain(tenant)
# product_xml = MessageSetup.first.product_xml
# client = Client.find 13
# events = Event.active.where(casetype: 'restock')
# RestockService.new(user, client, events, product_xml).do_action
