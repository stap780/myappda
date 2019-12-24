class ClientsController < ApplicationController
  before_action :set_client, only: [:show, :edit, :update, :destroy]

  # GET /clients
  # GET /clients.json
  def index
    # @clients = Client.all
    @search = Client.ransack(params[:q])
    @search.sorts = 'id desc' if @search.sorts.empty?
    @clients = @search.result.paginate(page: params[:page], per_page: 30)

    fio = []
    insint = current_user.insints.first
    if insint.present?
      @clients.each do |client|
      arr = []
      # uri = "http://"+"#{insint.subdomen}"+"/admin/clients/"+client.clientid+".json"
      uri = "http://k-comment:"+"#{insint.password}"+"@"+"#{insint.subdomen}"+"/admin/clients/"+client.clientid+".json"
      # auth = 'Basic ' + Base64.encode64( 'k-comment:'+"#{insint.password}" ).chomp
      # puts uri
      # RestClient.get( uri, :Authorization => auth, :content_type => :json, :accept => :json) { |response, request, result, &block|
      RestClient.get( uri, :content_type => :json, :accept => :json) { |response, request, result, &block|
              case response.code
              when 200
                data = JSON.parse(response)
                name = data['name'] || ''
                surname = data['surname'] || ''

                arr.push(client.id, name+" "+surname)

              when 404
                arr.push(client.id, "")
              else
                response.return!(&block)
              end
              }
      fio.push(arr)
      end
      fioHash = Hash[fio]
      @full_clients = @clients.map{|client| client.attributes.merge({'fio' => fioHash[client.id]})}
    else
        @full_clients = @clients
    end

# puts @full_clients

  end

  # GET /clients/1
  # GET /clients/1.json
  def show
    @fio = params["fio"]
    pr_datas = []
    insint = current_user.insints.first
      @client.izb_productid.split(',').each do |pr|
        uri = "http://"+"#{insint.subdomen}"+"/admin/products/"+pr+".json"
        auth = 'Basic ' + Base64.encode64( 'k-comment:'+"#{insint.password}" ).chomp
        RestClient.get( uri, :Authorization => auth, :content_type => :json, :accept => :json) { |response, request, result, &block|
                case response.code
                when 200
                  data = JSON.parse(response)
                  title = data['title'] || ''
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
      format.html { redirect_to clients_url, notice: 'Client was successfully destroyed.' }
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
      params.require(:client).permit(:clientid, :izb_productid)
    end
end
