class DashboardController < ApplicationController
  before_action :authenticate_user!

  def index
    insint = current_user.insints.first
    clients = Client.all
    service = current_user.insints.first.present? ? ApiInsales.new(current_user.insints.first) : nil
    @ins_account = service.present? && service.work? ? service.account : nil

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
    flash[:notice] = 'Отправили'
		redirect_to dashboard_path
  end

  def services
    @favorite_setup = FavoriteSetup.first
    @restock_setup = RestockSetup.first
    @message_setup = MessageSetup.first
  end


end
