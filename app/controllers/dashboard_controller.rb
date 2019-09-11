class DashboardController < ApplicationController
  def index
    insint = Insint.find(current_user.id)
    uri = "http://k-comment:"+insint.password+"@"+insint.subdomen+"/admin/products/count.json"
    response = RestClient.get(uri)
    data = JSON.parse(response)
    @product_count = data['count']
  end # index
end # index
