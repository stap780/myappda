class ClientsController < ApplicationController
  before_action :authenticate_user!
  before_action :set_client, only: [:show, :edit, :update, :emailizb, :destroy]

  # GET /clients
  # GET /clients.json
  def index
    @search = Client.ransack(params[:q])
    @search.sorts = 'id desc' if @search.sorts.empty?
    @clients = @search.result.paginate(page: params[:page], per_page: 50)
  end

  # GET /clients/1
  # GET /clients/1.json
  def show
    @favorite_products = Product.where(id: @client.favorites.pluck(:product_id))
    @restock_products = Variant.where(id: @client.restocks.pluck(:variant_id))
  end

  # GET /clients/new
  def new
    @client = Client.new
  end

  # GET /clients/1/edit
  def edit
  end

  def otchet
    current_subdomain = Apartment::Tenant.current
    current_user_id = current_user.id
    Client.otchet(current_subdomain, current_user_id)
    # check_status = true
    respond_to do |format|
      format.js do
          flash.now[:notice] = "Файл создан <a href='/#{current_user_id.to_s}_clients_izb.csv'>Скачать</a>"
      end
    end
  end

  def emailizb
    user_client_id = params[:id]
    current_subdomain = Apartment::Tenant.current
    current_user_id = current_user.id
    Client.emailizb(current_subdomain, user_client_id, current_user_id)
    respond_to do |format|
      format.js do
          flash.now[:notice] = "Письмо с товарами отправлено"
      end
    end
  end

  # POST /clients
  # POST /clients.json
  def create
    @client = Client.new(client_params)
    respond_to do |format|
      if @client.save
        format.html { redirect_to @client, notice: 'Client was successfully created.' }
        format.json { render :show, status: :created, location: @client }
      else
        format.html { render :new }
        format.json { render json: @client.errors, status: :unprocessable_entity }
      end
    end
  end

  # PATCH/PUT /clients/1
  # PATCH/PUT /clients/1.json
  def update
    respond_to do |format|
      if @client.update(client_params)
        format.html { redirect_to @client, notice: 'Client was successfully updated.' }
        format.json { render :show, status: :ok, location: @client }
      else
        format.html { render :edit }
        format.json { render json: @client.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /clients/1
  # DELETE /clients/1.json
  def destroy
    @client.destroy
    respond_to do |format|
      format.html { redirect_to clients_url, notice: 'Данные по клиенту удалены.' }
      format.json { head :no_content }
    end
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_client
      @client = Client.find(params[:id])
    end

    # Never trust parameters from the scary internet, only allow the white list through.
    def client_params
      params.require(:client).permit(:clientid, :izb_productid, :name, :surname, :email, :phone)
    end
end
