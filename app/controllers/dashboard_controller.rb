class DashboardController < ApplicationController
  def index
    insint = current_user.insints.first
    if insint.present?
      uri = "http://k-comment:"+"#{insint.password}"+"@"+"#{insint.subdomen}"+"/admin/products/count.json"
      puts uri
      response = RestClient.get(uri)
      data = JSON.parse(response)
      @product_count = data['count']
    end
    clients = Client.all
    izb_product_string = clients.map(&:izb_productid).join(',')
    @count_izb = izb_product_string.split(',').count

  end # index
  
end # index
