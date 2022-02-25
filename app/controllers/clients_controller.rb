class ClientsController < ApplicationController
  before_action :authenticate_user!
  before_action :set_client, only: [:show, :edit, :update, :destroy]

  # GET /clients
  # GET /clients.json
  def index
    @search = Client.ransack(params[:q])
    @search.sorts = 'id desc' if @search.sorts.empty?
    @clients = @search.result.paginate(page: params[:page], per_page: 50)
  end

  def index_old
    @search = Client.ransack(params[:q])
    @search.sorts = 'id desc' if @search.sorts.empty?
    @clients = @search.result.paginate(page: params[:page], per_page: 30)

    fio = []
    email_data = []
    insint = current_user.insints.first
    if insint.present?
      # puts @clients.count
      @clients.each do |client|
        arr_fio = []
        arr_email = []
        if insint.inskey.present?
          uri = "http://"+"#{insint.inskey}"+":"+"#{insint.password}"+"@"+"#{insint.subdomen}"+"/admin/clients/"+"#{client.clientid}"+".json"
        else
          uri = "http://k-comment:"+"#{insint.password}"+"@"+"#{insint.subdomen}"+"/admin/clients/"+"#{client.clientid}"+".json"
        end
        RestClient.get( uri, :content_type => :json, :accept => :json) { |response, request, result, &block|
                case response.code
                when 200
                  data = JSON.parse(response)
                  name = data['name'] || ''
                  surname = data['surname'] || ''
                  email = data['email'] || ''
                  arr_fio.push(client.id, name+" "+surname)
                  arr_email.push(client.id, email)
                when 404
                  arr_fio.push(client.id, '')
                  arr_email.push(client.id, '')
                when 403
                  arr_fio.push(client.id, '')
                  arr_email.push(client.id, '')
                else
                  response.return!(&block)
                end
                }
        fio.push(arr_fio)
        email_data.push(arr_email)
      end
      fioHash = Hash[fio]
      emailHash = Hash[email_data]
      @full_clients = @clients.map{|client| client.attributes.merge({'fio' => fioHash[client.id],'email' => emailHash[client.id]})}
    else
      @full_clients = @clients
    end

  end

  # GET /clients/1
  # GET /clients/1.json
  def show
  end

  def show_old
    pr_datas = []
    insint = current_user.insints.first
    if insint.inskey.present?
      uri = "http://"+"#{insint.inskey}"+":"+"#{insint.password}"+"@"+"#{insint.subdomen}"
    else
      uri = "http://k-comment:"+"#{insint.password}"+"@"+"#{insint.subdomen}"
    end
      @client.izb_productid.split(',').each do |pr|
        RestClient.get( uri+"/admin/products/"+pr+".json", :content_type => :json, :accept => :json) { |response, request, result, &block|
                case response.code
                when 200
                  data = JSON.parse(response)
                  title = data['title'].to_s.gsub(',',' ') || ''
                  permalink = data['permalink'] || ''
                  if data['images'].present?
                    image = data['images'][0]['small_url']
                  else
                    image = ''
                  end
                  price = data['variants'][0]['price'] || ''
                  save_data = pr+","+title+","+permalink+","+image+","+price
                  pr_datas.push(save_data)
                when 404
                  save_data = pr+","+","+","+","
                  pr_datas.push(save_data)
                else
                  response.return!(&block)
                end
                }
      end
      @client_products = pr_datas
  end

  # GET /clients/new
  def new
    @client = Client.new
  end

  # GET /clients/1/edit
  def edit
  end

  def otchet
    Client.otchet
    # check_status = true
    respond_to do |format|
      format.js do
          flash.now[:notice] = "Файл создан <a href='/"+"#{current_user.id.to_s}"+"_clients_izb.csv'>Скачать</a>"
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
