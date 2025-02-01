#  encoding : utf-8

# ClientsController
class ClientsController < ApplicationController
  before_action :authenticate_user!
  before_action :set_client, only: %i[show edit update emailizb update_from_insales destroy]

  def index
    @search = Client.includes(:favorites, :restocks, :preorders, :abandoned_carts).ransack(params[:q])
    @search.sorts = 'id desc' if @search.sorts.empty?
    @clients = @search.result(distinct: true).paginate(page: params[:page], per_page: 50)
  end

  def show; end

  def new
    redirect_to clients_url, notice: t('clients.created_in_insales')
  end

  def edit
    redirect_to clients_url, notice: 'Клиенты редактируются в InSales'
  end

  def update_from_insales
    @client.get_ins_data
    redirect_to @client, notice: 'Обновили клиента.'
  end

  def otchet
    current_subdomain = Apartment::Tenant.current
    current_user_id = current_user.id
    Client.otchet(current_subdomain, current_user_id)
    respond_to do |format|
      flash.now[:success] = "Файл создан <a href='/#{current_user_id}_clients_izb.csv'>Скачать</a>".html_safe
      format.turbo_stream do
        render turbo_stream: [
          render_turbo_flash
        ]
      end
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
        format.html { redirect_to @client, notice: 'Client was successfully created.' }
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
        format.html { redirect_to @client, notice: 'Client was successfully updated.' }
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
      format.html { redirect_to clients_url, notice: 'Данные по клиенту удалены.' }
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
      flash[:alert] = "Ошибка в файле импорта"
    end
  end

  def update_api_insales
    Rails.env.development? ? Client::Insales.create_client(params, current_user.insints.first) : InsalesClientJob.perform_later(params.to_unsafe_hash, current_user.insints.first)
    redirect_to clients_url, notice: 'Запущен процесс создания контактов. Дождитесь выполнения процесса. Поступит уведомление на почту'
  end

  private

  def set_client
    @client = Client.find(params[:id])
  end

  def client_params
    params.require(:client).permit(:clientid, :name, :surname, :email, :phone)
  end
end
