class DashboardController < ApplicationController
  def index
    insint = current_user.insints.first
    uri = "http://k-comment:"+"#{insint.password}"+"@"+"#{insint.subdomen}"+"/admin/products/count.json"
    response = RestClient.get(uri)
    data = JSON.parse(response)
    @product_count = data['count']
  end # index
end # index
