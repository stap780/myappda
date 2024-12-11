# frozen_string_literal: true

# Restock::SetStatusForInform class
class Restock::SetStatusForInform < ApplicationService

  def initialize(tenant, xml_file)
    @tenant = tenant
    @xml_file = xml_file
  end

  def call
    restocks_update_status_for_inform
  end

  private

  def restocks_update_status_for_inform
    if File.file?(@xml_file).present?
      Apartment::Tenant.switch(@tenant) do
        all_offers = Nokogiri::XML(File.open(@xml_file)).xpath('//offer')
        Restock.status_wait.each do |res|
          ins_variant = all_offers.select { |offer| offer if offer['id'] == res.variant.insid.to_s }
          if ins_variant.present? && ins_variant[0]['available'] == 'true'
            # puts "=======restocks_update_status_for_inform #{res.inspect}"
            res.update!(status: 'ready')
          end
        end
      end
    end
  end

end