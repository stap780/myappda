class DashboardController < ApplicationController
  before_action :authenticate_user!

  def index
    insint = current_user.insints.first
    clients = Client.all
    service = Services::InsalesApi.new(current_user.insints.first)
    @ins_account = service.account

    # izb_product_string = clients.map(&:izb_productid).join(',')
    # @count_izb = izb_product_string.split(',').count
    # @clients_count = clients.count
    @clients_count = clients.count
    @count_izb = clients.map{|client| client.products.count}.sum
    respond_to do |format|
		  format.html
		end
  end

  def show
  end

  def test_email
    User.service_end_email
    # Client.emailizb('fishartel', 29250124, 64 ) #development test
    # Client.emailizb('insales22810', 27968659, 20 ) #production test
    flash[:notice] = 'Отправили'
		redirect_to dashboard_path
  end

  def services
    @favorite_setup = FavoriteSetup.first
    @restock_setup = RestockSetup.first
    @message_setup = MessageSetup.first
  end


end
