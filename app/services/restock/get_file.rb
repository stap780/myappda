# frozen_string_literal: true

# Restock::GetFile class
class Restock::GetFile < ApplicationService

  def initialize(product_xml)
    @product_xml = product_xml
    @file = nil
  end

  def call
    load_products_xml if check_product_xml_work
    @file.present? ? @file : false
  end

  private

  def check_product_xml_work
    check = true
    begin
      response = RestClient.get(@product_xml)
    rescue SocketError => e
      puts "In Socket errror"
      puts e
      check = false
    rescue => e
      puts(e.class.inspect)
      check = false
    else
      check
    end
  end

  def load_products_xml
    filename = @product_xml.split('/').last
    download_path = Rails.env.development? ? "#{Rails.root}/public/#{filename}" : "/var/www/myappda/shared/public/#{filename}"
    File.delete(download_path) if File.file?(download_path).present?
    file = ''
    RestClient.get(@product_xml) { |response, request, result, &block|
      # puts response.code
      # puts response
      case response.code
      when 200
        f = File.new(download_path, 'wb')
        f << response.body
        f.close
        file = download_path
      when 301
        puts "load_products_xml error 301 - это редирект у файла с технического домена на реальный домен. нужно в настройках поменять ссылку на файл"
      else
        response.return!(&block)
      end
    }
    @file = file
  end

end