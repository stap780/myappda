class InsintsController < ApplicationController
  before_action :authenticate_user! , except: [:install, :uninstall, :login, :addizb, :getizb, :deleteizb, :setup_script, :emailizb]
  before_action :set_insint, only: [:show, :edit, :update, :destroy]

  # GET /insints
  # GET /insints.json
  def index
    @insints = current_user.insints
  end

  def adminindex
    @search = Insint.ransack(params[:q])
    @search.sorts = 'id desc' if @search.sorts.empty?
    @insints = @search.result.paginate(page: params[:page], per_page: 30)
  end


  # GET /insints/1
  # GET /insints/1.json
  def show
  end

  # GET /insints/new
  def new
    @insint = Insint.new
  end

  # GET /insints/1/edit
  def edit
  end

  # POST /insints
  # POST /insints.json
  def create
    @insint = Insint.new(insint_params)

    respond_to do |format|
      if @insint.save
        format.html { redirect_to @insint, notice: 'Insint was successfully created.' }
        format.json { render :show, status: :created, location: @insint }
      else
        format.html { render :new }
        format.json { render json: @insint.errors, status: :unprocessable_entity }
      end
    end
  end

  # PATCH/PUT /insints/1
  # PATCH/PUT /insints/1.json
  def update
    respond_to do |format|
      if @insint.update(insint_params)
        format.html { redirect_to @insint, notice: 'Insint was successfully updated.' }
        format.json { render :show, status: :ok, location: @insint }
      else
        format.html { render :edit }
        format.json { render json: @insint.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /insints/1
  # DELETE /insints/1.json
  def destroy
    @insint.destroy
    respond_to do |format|
      format.html { redirect_to insints_url, notice: 'Insint was successfully destroyed.' }
      format.json { head :no_content }
    end
  end

  def install
    puts params[:insales_id]
    @insint = Insint.find_by_insalesid(params[:insales_id])
    if @insint.present?
      puts "есть пользователь insint"
    else
      save_subdomain = "insales"+params[:insales_id]
      email = save_subdomain+"@mail.ru"
      puts save_subdomain
      user = User.create(:name => params[:insales_id], :subdomain => save_subdomain, :password => save_subdomain, :password_confirmation => save_subdomain, :email => email)
      user.valid_from = user.created_at
      user.valid_until = user.created_at + 7.days
      user.save
      #puts user.id
      secret_key = 'my_test_secret_key'
      password = Digest::MD5.hexdigest(params[:token] + secret_key)
      insint_new = Insint.create(:subdomen => params[:shop],  password: password, insalesid: params[:insales_id], :user_id => user.id)
      Insint.setup_ins_shop(insint_new.id)
      head :ok
    end
  end

  def uninstall
    @insint = Insint.find_by_insalesid(params[:insales_id])
    saved_subdomain = "insales"+params[:insales_id]
    @user = User.find_by_subdomain(saved_subdomain)
    if @insint.present?
      Insint.delete_ins_file(@insint.id)
      puts "удаляем пользователя insint - ""#{@insint.id}"
      @insint.delete
      @user.delete
      Apartment::Tenant.drop(saved_subdomain)
      head :ok
    end
  end

  def login
    @insint = Insint.find_by_insalesid(params[:insales_id])
    saved_subdomain = "insales"+params[:insales_id]
    Apartment::Tenant.switch!(saved_subdomain)
    @user = User.find_by_subdomain(saved_subdomain)
    if @user.present?
      if @insint.present?
        user_account = Useraccount.find_by_insuserid(params[:user_id])
        if user_account.present?
          name = params[:user_id]+params[:shop]
          user_account.update_attributes(:shop => params[:shop], :email => params[:user_email], :insuserid => params[:user_id], :name => name)
          puts @user.valid_until
          if @user.valid_until <= Date.today
            puts "время работы истекло - ставим плюс 1 день чтобы клиент сформировал себе счет на оплату"
            @user.valid_until = Date.today
            @user.save
            sign_in(:user, @user)
            # redirect_to after_sign_in_path_for(@user)
            redirect_to invoice_path_for(@user), :notice => 'Оплаченный период истёк. Сервис не работает для Ваших клиентов. Пожалуйста оплатите сервис.'
          else
            sign_in(:user, @user)
            redirect_to after_sign_in_path_for(@user)
            # sign_in_and_redirect(:user, @user)
          end
        else
          name = params[:user_id]+params[:shop]
          user_account = Useraccount.create(:shop => params[:shop], :email => params[:user_email], :insuserid => params[:user_id], :name => name)
          sign_in(:user, @user)
          redirect_to after_sign_in_path_for(@user)
        end
      end
    end
  end

  def addizb
    @insint = Insint.find_by_subdomen(params[:host])
    if @insint.inskey.present?
      saved_subdomain = @insint.user.subdomain
    else
      saved_subdomain = "insales"+@insint.insalesid.to_s
    end
    Apartment::Tenant.switch!(saved_subdomain)
    @user = User.find_by_subdomain(saved_subdomain)
    if @user.present?
      if Date.today < @user.valid_until
        client = Client.find_by_clientid(params[:client_id])
        if client.present?
          izb_productid = client.izb_productid.split(',').push(params[:product_id]).uniq.join(',')
          client.update_attributes(:izb_productid => izb_productid )
          render :json=> {:success=>true, :message=>"товар добавлен в избранное"}
        else
          Client.create(:clientid => params[:client_id], :izb_productid => params[:product_id])
          render :json=> {:success=>true, :message=>"товар добавлен в избранное"}
        end
      else
        render :json=> {:error=>false, :message=>"истёк срок оплаты сервиса, товары не добавляются"}
      end
    end
    # head :ok
  end

  def getizb
    @insint = Insint.find_by_subdomen(params[:host])
    if @insint.inskey.present?
      saved_subdomain = @insint.user.subdomain
    else
      saved_subdomain = "insales"+@insint.insalesid.to_s
    end
    Apartment::Tenant.switch!(saved_subdomain)
    @user = User.find_by_subdomain(saved_subdomain)
    if @user.present?
      # if Date.today < @user.valid_until
        client = Client.find_by_clientid(params[:client_id])
        if client.present?
          render :json=> {:success=>true, :products =>client.izb_productid}
        else
          render :json=> {:error=>false, :message=>"нет такого клиента"}
        end
      # else
      #   render :json=> {:success=>true, :message=>"истёк срок оплаты сервиса"}
      # end
    end
  end

  def deleteizb
    @insint = Insint.find_by_subdomen(params[:host])
    if @insint.inskey.present?
      saved_subdomain = @insint.user.subdomain
    else
      saved_subdomain = "insales"+@insint.insalesid.to_s
    end
    Apartment::Tenant.switch!(saved_subdomain)
    @user = User.find_by_subdomain(saved_subdomain)
    if @user.present?

        client = Client.find_by_clientid(params[:client_id])
        if client.present?
          products = client.izb_productid
          puts products
          if products.include?(params[:product_id])
            ecxlude_string = []
            ecxlude_string.push(params[:product_id])
            products = ( client.izb_productid.split(',') - ecxlude_string ).uniq.join(',')
            puts products
            client.update_attributes( :izb_productid => products )
            render :json=> {:success=>true, :message=>"товар удалён"}
          else
            render :json=> {:error=>false, :message=>"нет такого товара"}
          end
        end

    end
  end

  def emailizb
    @insint = Insint.find_by_subdomen(params[:host])
    if @insint.inskey.present?
      saved_subdomain = @insint.user.subdomain
    else
      saved_subdomain = "insales"+@insint.insalesid.to_s
    end
    Apartment::Tenant.switch!(saved_subdomain)
    @user = User.find_by_subdomain(saved_subdomain)
    if @user.present?
      # if Date.today < @user.valid_until
        client = Client.find_by_clientid(params[:client_id])
        if client.present?
          Cient.emailizb(saved_subdomain, client.id, @user.id)
          render :json=> {:success=>true, :message=>"Товары отправленны Вам на почту"}
        else
          render :json=> {:error=>false, :message=>"нет такого клиента"}
        end
      # else
      #   render :json=> {:success=>true, :message=>"истёк срок оплаты сервиса"}
      # end
    end
  end

  def setup_script
    Insint.setup_ins_shop(params[:insint_id])
    respond_to do |format|
        # format.html { :controller => 'useraccount', :action => 'index', notice: 'Скрипты добавлены в магазин' }
        format.html { redirect_to useraccounts_url, notice: 'Скрипты добавлены в магазин' }
    end
  end

  def delete_script
    Insint.delete_ins_file(params[:insint_id])
    respond_to do |format|
        # format.html { :controller => 'useraccount', :action => 'index', notice: 'Скрипты добавлены в магазин' }
        format.html { redirect_to useraccounts_url, notice: 'Скрипты удалены из магазин' }
    end
  end

  def checkint
    insint = Insint.find(params[:insint_id])
    if insint.inskey.present?
      uri = "http://"+"#{insint.inskey}"+":"+"#{insint.password}"+"@"+"#{insint.subdomen}"+"/admin/account.json"
    else
      uri = "http://k-comment.ru"+":"+"#{insint.password}"+"@"+"#{insint.subdomen}"+"/admin/account.json"
    end

    RestClient.get( uri, {:content_type => 'application/json', accept: :json}) { |response, request, result, &block|
            case response.code
            when 200
              @check_status = true
            when 401
              @check_status = false
            else
              response.return!(&block)
            end
            }
    respond_to do |format|
        format.js do
          if @check_status == true
            flash.now[:notice] = "Интеграция работает!"
          end
          if @check_status == false
            flash.now[:error] = "Не работает интеграция!"
          end
        end
      end
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_insint
      @insint = Insint.find(params[:id])
    end

    # Never trust parameters from the scary internet, only allow the white list through.
    def insint_params
      params.require(:insint).permit(:subdomen, :password, :insalesid, :user_id, :inskey, :status)
    end
end
