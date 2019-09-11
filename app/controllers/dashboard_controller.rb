class DashboardController < ApplicationController
  def index
    searchid = current_user.id
    insint = Insint.find(searchid)
    uri = "http://k-comment:"+insint.password+"@"+insint.subdomen+"/admin/products/count.json"
    response = RestClient.get(uri)
    data = JSON.parse(response)
    @product_count = data['count']
  end # index
end # index
