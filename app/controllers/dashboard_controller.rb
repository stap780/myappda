class DashboardController < ApplicationController

  def index
    insint = current_user.insints.first
    # if insint.present?
      # if insint.inskey.present?
      #   uri = "http://"+"#{insint.inskey}"+":"+"#{insint.password}"+"@"+"#{insint.subdomen}"+"/admin/products/count.json"
      # else
      #   uri = "http://k-comment:"+"#{insint.password}"+"@"+"#{insint.subdomen}"+"/admin/products/count.json"
      #   url = "http://k-comment:"+"#{insint.password}"+"@"+"#{insint.subdomen}"+"/admin/account.json"
      # end
      #   puts uri
        # response = RestClient.get(uri)
        # data = JSON.parse(response)
        # @product_count = data['count']
    # end
    clients = Client.all
    # izb_product_string = clients.map(&:izb_productid).join(',')
    # @count_izb = izb_product_string.split(',').count
    # @clients_count = clients.count
    @clients_count = clients.count
    @count_izb = clients.map{|client| client.products.count}.sum
    respond_to do |format|
		  format.html
		end
  end # index

  def user
  end

  def user_edit
    # puts current_user.id
    if current_user.id == params[:user_id].to_i
      @user = User.find(params[:user_id])
    else
      redirect_to dashboard_user_path
    end
  end


  def test_email
    User.service_end_email
    # Client.emailizb('fishartel', 29250124, 64 ) #development test
    # Client.emailizb('insales22810', 27968659, 20 ) #production test
    flash[:notice] = 'Отправили'
		redirect_to dashboard_index_path
  end

  def services
    @favorite_setup = FavoriteSetup.first
    puts @favorite_setup.present?
    @restock_setup = RestockSetup.first
  end


end # index
