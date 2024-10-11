class ClientsController < ApplicationController
  before_action :authenticate_user!
  before_action :set_client, only: [:show, :edit, :update, :emailizb, :update_from_insales, :destroy]

  def index
    @search = Client.includes(:favorites, :restocks, :preorders).ransack(params[:q])
    @search.sorts = "id desc" if @search.sorts.empty?
    @clients = @search.result(distinct: true).paginate(page: params[:page], per_page: 30)
  end

  def show
    @favorite_products = Product.where(id: @client.favorites.pluck(:product_id))
    # @restock_products = Variant.where(id: @client.restocks.pluck(:variant_id))
  end

  def new
    # @client = Client.new
    redirect_to clients_url, notice: "\u041A\u043B\u0438\u0435\u043D\u0442\u044B \u0441\u043E\u0437\u0434\u0430\u044E\u0442\u0441\u044F \u0432 InSales"
  end

  def edit
    redirect_to clients_url, notice: "\u041A\u043B\u0438\u0435\u043D\u0442\u044B \u0440\u0435\u0434\u0430\u043A\u0442\u0438\u0440\u0443\u044E\u0442\u0441\u044F \u0432 InSales"
  end

  def update_from_insales
    @client.get_ins_client_data
    redirect_to @client, notice: "\u041E\u0431\u043D\u043E\u0432\u0438\u043B\u0438 \u043A\u043B\u0438\u0435\u043D\u0442\u0430."
  end

  def otchet
    current_subdomain = Apartment::Tenant.current
    current_user_id = current_user.id
    Client.otchet(current_subdomain, current_user_id)
    # check_status = true
    respond_to do |format|
      flash.now[:success] = "Файл создан <a href='/#{current_user_id}_clients_izb.csv'>Скачать</a>".html_safe
      format.turbo_stream do
        render turbo_stream: [
          render_turbo_flash
        ]
      end
      # format.js do
      #     flash.now[:notice] = "Файл создан <a href='/#{current_user_id.to_s}_clients_izb.csv'>Скачать</a>".html_safe
      # end
    end
  end

  def emailizb
    current_subdomain = Apartment::Tenant.current
    current_user_id = current_user.id
    result, notice = @client.emailizb(current_subdomain, current_user)
    respond_to do |format|
      flash.now[:success] = notice
      format.turbo_stream do
        render turbo_stream: [
          render_turbo_flash
        ]
      end
    end
  end

  def create
    @client = Client.new(client_params)
    respond_to do |format|
      if @client.save
        format.html { redirect_to @client, notice: "Client was successfully created." }
        format.json { render :show, status: :created, location: @client }
      else
        format.html { render :new }
        format.json { render json: @client.errors, status: :unprocessable_entity }
      end
    end
  end

  def update
    respond_to do |format|
      if @client.update(client_params)
        format.html { redirect_to @client, notice: "Client was successfully updated." }
        format.json { render :show, status: :ok, location: @client }
      else
        format.html { render :edit }
        format.json { render json: @client.errors, status: :unprocessable_entity }
      end
    end
  end

  def destroy
    @client.destroy
    respond_to do |format|
      format.html { redirect_to clients_url, notice: "\u0414\u0430\u043D\u043D\u044B\u0435 \u043F\u043E \u043A\u043B\u0438\u0435\u043D\u0442\u0443 \u0443\u0434\u0430\u043B\u0435\u043D\u044B." }
      format.json { head :no_content }
    end
  end

  # это для модалки для загрузки файла
  def file_import_insales
    respond_to do |format|
      format.turbo_stream
    end
  end

  def import
    # оставил для стандартного импорта к нам в систему
  end

  def import_insales_setup
    service = Client::Import.new(params[:file])
    client_import_data = service.collect_data
    if client_import_data
      @header = client_import_data[:header]
      @client_data = client_import_data[:client_data]
      service = ApiInsales.new(current_user.insints.first)
      @insales_fields = service.client_fields
    else
      flash[:alert] = "\u041E\u0448\u0438\u0431\u043A\u0430 \u0432 \u0444\u0430\u0439\u043B\u0435 \u0438\u043C\u043F\u043E\u0440\u0442\u0430"
    end
  end

  def update_api_insales
    Rails.env.development? ? Client::Insales.create_client(params, current_user.insints.first) : InsalesClientJob.perform_later(params.to_unsafe_hash, current_user.insints.first)
    redirect_to clients_url, notice: "\u0417\u0430\u043F\u0443\u0449\u0435\u043D \u043F\u0440\u043E\u0446\u0435\u0441\u0441 \u0441\u043E\u0437\u0434\u0430\u043D\u0438\u044F \u043A\u043E\u043D\u0442\u0430\u043A\u0442\u043E\u0432. \u0414\u043E\u0436\u0434\u0438\u0442\u0435\u0441\u044C \u0432\u044B\u043F\u043E\u043B\u043D\u0435\u043D\u0438\u0438 \u043F\u0440\u043E\u0446\u0435\u0441\u0441\u0430. \u041F\u043E\u0441\u0442\u0443\u043F\u0438\u0442 \u0443\u0432\u0435\u0434\u043E\u043C\u043B\u0435\u043D\u0438\u0435 \u043D\u0430 \u043F\u043E\u0447\u0442\u0443"
  end

  private

  # Use callbacks to share common setup or constraints between actions.
  def set_client
    @client = Client.find(params[:id])
  end

  # Never trust parameters from the scary internet, only allow the white list through.
  def client_params
    params.require(:client).permit(:clientid, :izb_productid, :name, :surname, :email, :phone, :update_rules, :client_lines)
  end
end
