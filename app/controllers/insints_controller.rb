class InsintsController < ApplicationController
  before_action :authenticate_user!, except: %i[install uninstall login addizb getizb deleteizb emailizb addrestock order]
  before_action :authenticate_admin!, only: %i[adminindex]
  before_action :set_insint, only: %i[show edit update check destroy]

  # GET /insints
  # GET /insints.json
  def index
    @insints = current_user.insints if !current_admin
  end

  def adminindex
    @search = Insint.ransack(params[:q])
    @search.sorts = 'id desc' if @search.sorts.empty?
    @insints = @search.result.paginate(page: params[:page], per_page: 30)
  end

  # GET /insints/1
  def show
    redirect_to useraccounts_url, alert: 'Access denied.' unless @insint.user == current_use
  end

  # GET /insints/new
  def new
    if current_user.insints.count == 0
      @insint = Insint.new
    else
      redirect_to dashboard_url, notice: 'У Вас уже есть интеграция'
    end
  end

  # GET /insints/1/edit
  def edit
    redirect_to dashboard_url, alert: 'Access denied.' unless @insint.user == current_user
  end

  # POST /insints
  def create
    @insint = Insint.new(insint_params)
    respond_to do |format|
      if @insint.save
        service = Services::InsalesApi.new(@insint)
        service.work? ? @insint.update!(status: true) : @insint.update!(status: false)
        notice = service.work? == true ? 'Интеграция insales создана. Интеграция работает!' : 'Интеграция insales создана. Не работает!'
        format.html { redirect_to dashboard_url, notice: notice }
        format.json { render :show, status: :created, location: @insint }
      else
        format.html { render :new }
        format.json { render json: @insint.errors, status: :unprocessable_entity }
      end
    end
  end

  # PATCH/PUT /insints/1
  def update
    respond_to do |format|
      if @insint.update(insint_params)
          service = Services::InsalesApi.new(@insint)
          service.work? ? @insint.update!(status: true) : @insint.update!(status: false)
          notice = service.work? == true ? 'Интеграция insales обновлена. Интеграция работает!' : 'Интеграция insales обновлена. Не работает!'
          redirect_path = current_admin ? adminindex_insints_url : insints_url
          format.html { redirect_to redirect_path, notice: notice }
          format.json { render :show, status: :ok, location: @insint }
        else
          format.html { render :edit, notice: 'Проверьте данные, интеграция не работает'  }
          format.json { render json: @insint.errors, status: :unprocessable_entity }
        end
    end
  end

  # DELETE /insints/1
  def destroy
    @insint.destroy
    respond_to do |format|
      format.html { redirect_to insints_url, notice: 'Insint was successfully destroyed.' }
      format.json { head :no_content }
    end
  end

  def install
    # puts params[:insales_id]
    @insint = Insint.find_by_insales_account_id(params[:insales_id])
    if @insint.present?
      puts 'есть βυντθηφςβζ insint'
    else
      save_subdomain = 'insales' + params[:insales_id]
      email = save_subdomain + '@mail.ru'
      # puts save_subdomain
      user = User.create(name: params[:insales_id], subdomain: save_subdomain, password: save_subdomain,
                         password_confirmation: save_subdomain, email: email, valid_from: Date.today, valid_until: 'Sat, 30 Dec 2024')
      secret_key = ENV['INS_APP_SECRET_KEY']
      password = Digest::MD5.hexdigest(params[:token] + secret_key)
      Insint.create(subdomen: params[:shop], password: password, insales_account_id: params[:insales_id], user_id: user.id, status: true, inskey: 'k-comment')
      head :ok
    end
  end

  def uninstall
    @insint = Insint.find_by_insales_account_id(params[:insales_id])
    saved_subdomain = 'insales' + params[:insales_id]
    @user = User.find_by_subdomain(saved_subdomain)
    if @insint.present?
      Insint.delete_ins_file(@insint.id)
      puts 'удаляем пользователя insint - '"#{@insint.id}"
      @insint.delete
      @user.delete
      Apartment::Tenant.drop(saved_subdomain)
      head :ok
    end
  end

  def login
    saved_subdomain = 'insales' + params[:insales_id]
    user = User.find_by_subdomain(saved_subdomain)
    insint = user.insints.first
    if user.present? && insint.present?
      Apartment::Tenant.switch(saved_subdomain) do
        user_account = Useraccount.find_by_insuserid(params[:user_id])
        user_name = params[:user_id] + params[:shop]
        Useraccount.create(shop: params[:shop], email: params[:user_email], insuserid: params[:user_id], name: user_name) if !user_account.present?
      end
      sign_in(:user, user)
      redirect_to after_sign_in_path_for(user)
    end
  end

  def addizb
    insint = Insint.find_by_subdomen(params[:host])
    saved_subdomain = insint.inskey.present? ? insint.user.subdomain : 'insales' + insint.insales_account_id.to_s
    if saved_subdomain != "mamamila" || saved_subdomain != "insales753667"
      Apartment::Tenant.switch(saved_subdomain) do
        if FavoriteSetup.check_ability
          client = Client.find_by_clientid(params[:client_id])
          if client.present?
            # izb_productid = client.izb_productid.split(',').push(params[:product_id]).uniq.join(',')
            # client.update_attributes(izb_productid: izb_productid)
            # totalcount = client.izb_productid.split(',').count
            #добавка после расширения функционала
            product = Product.find_by(insid: params[:product_id]).present? ? Product.find_by(insid: params[:product_id]) : Product.create(insid: params[:product_id])
            client.favorites.create!(product_id: product.id)
            totalcount = client.favorites.count.to_s
            product.get_ins_product_data
            #конец добавка после расширения функционала
            render json: { success: true, message: 'товар добавлен в избранное', totalcount: totalcount }
          else
            service = Services::InsalesApi.new(insint)
            search_client = service.client(params[:client_id])
            new_client_data = {
              clientid: params[:client_id],
              name: search_client.name,
              surname: search_client.surname,
              email: search_client.email,
              phone: search_client.phone
            }
            new_client = Client.create!(new_client_data)
            # totalcount = new_client.izb_productid.split(',').count
            #добавка после расширения функционала
            product = Product.find_by(insid: params[:product_id]).present? ? Product.find_by(insid: params[:product_id]) : Product.create(insid: params[:product_id])
            new_client.favorites.create!(product_id: product.id)
            totalcount = new_client.favorites.count.to_s
            product.get_ins_product_data
            #конец добавка после расширения функционала
            render json: { success: true, message: 'товар добавлен в избранное', totalcount: totalcount }
          end
        else
          render json: { error: false, message: 'Кол-во клиентов больше допустимого, товары не добавляются' }
        end
      end
    else
      render json: { error: false, message: 'Сервис Избранное не оплачен. Приносим свои извинения. Ваша история не исчезла.' }
    end
  end

  def getizb
    insint = Insint.find_by_subdomen(params[:host])
    saved_subdomain = insint.user.subdomain
    if saved_subdomain != "mamamila" || saved_subdomain != "insales753667"
      Apartment::Tenant.switch(saved_subdomain) do
          client = Client.find_by_clientid(params[:client_id])
          if client.present?
            # totalcount = client.izb_productid.split(',').count
            favorite_product_ids = client.favorites.pluck(:product_id)
            ins_ids = client.products.where(id: favorite_product_ids).pluck(:insid).join(',')
            totalcount = client.favorites.count.to_s
            render json: { success: true, products: ins_ids, totalcount: totalcount }
          else
            render json: { error: false, message: 'нет такого клиента' }
          end
      end
    else
      render json: { error: false, message: 'Сервис Избранное не оплачен. Приносим свои извинения. Ваша история не исчезла.' }
    end
  end

  def deleteizb
    insint = Insint.find_by_subdomen(params[:host])
    saved_subdomain = insint.user.subdomain
    if saved_subdomain != "mamamila" || saved_subdomain != "insales753667"
      Apartment::Tenant.switch(saved_subdomain) do
        if FavoriteSetup.check_ability
          client = Client.find_by_clientid(params[:client_id])
          if client.present?
            product = Product.find_by_insid(params[:product_id])
            client.favorites.find_by_product_id(product.id).destroy #добавка после расширения функционала
            totalcount = client.favorites.count.to_s
            render json: { success: true, message: 'товар удалён', totalcount: totalcount }

            # products = client.izb_productid
            # # puts products
            # if products.include?(params[:product_id])
            #   ecxlude_string = []
            #   ecxlude_string.push(params[:product_id])
            #   products = (client.izb_productid.split(',') - ecxlude_string).uniq.join(',')
            #   # puts products
            #   client.update_attributes(izb_productid: products)
            #   # totalcount = client.izb_productid.split(',').count
            #   totalcount = client.favorites.count.to_s
            #   product = Product.find_by_insid(params[:product_id])
            #   client.favorites.find_by_product_id(product).destroy #добавка после расширения функционала
            #   render json: { success: true, message: 'товар удалён', totalcount: totalcount }
            # else
            #   render json: { error: false, message: 'нет такого товара' }
            # end
          end
        else
          render :json=> {:success=>true, :message=>"Кол-во клиентов больше допустимого, товары не удаляются"}
        end
      end
    else
      render json: { error: false, message: 'Сервис Избранное не оплачен. Приносим свои извинения. Ваша история не исчезла.' }
    end
  end

  def emailizb
    insint = Insint.find_by_subdomen(params[:host])
    saved_subdomain = insint.inskey.present? ? insint.user.subdomain : 'insales' + insint.insales_account_id.to_s
    if saved_subdomain != "mamamila" || saved_subdomain != "insales753667"
      Apartment::Tenant.switch(saved_subdomain) do
        if FavoriteSetup.check_ability
          client = Client.find_by_clientid(params[:client_id])
          if client.present?
            Client.emailizb(saved_subdomain, client.id, insint.user.id)
            render json: { success: true, message: 'Товары отправлены Вам на почту' }
          else
            render json: { error: false, message: 'нет такого клиента' }
          end
        else
          render :json=> {error: false, message: "Кол-во клиентов больше допустимого, письма не отправляются"}
        end
      end
    else
      render json: { error: false, message: 'Сервис Избранное не оплачен. Приносим свои извинения. Ваша история не исчезла.' }
    end
  end

  def check
    @insint = Insint.find(params[:id])
    service = Services::InsalesApi.new(@insint)
    notice = service.work? == true ? 'Интеграция работает!' : 'Не работает интеграция!'
    respond_to do |format|
      format.js do
        flash.now[:notice] = notice
      end
    end
  end

  def addrestock
    insint = Insint.find_by_subdomen(params[:host])
    saved_subdomain = insint.inskey.present? ? insint.user.subdomain : 'insales' + insint.insales_account_id.to_s
    Apartment::Tenant.switch(saved_subdomain) do
      if RestockSetup.check_ability
        client = Client.find_by_email(params[:client_email])
        if client.present?
          product = Product.find_or_create_by(insid: params[:product_id]) #добавка после расширения функционала
          variant = product.variants.find_or_create_by(insid: params[:variant_id])
          client.restocks.create(variant_id: variant.id) #добавка после расширения функционала
          render json: { success: true, message: 'Информация сохранена. Мы известим вас о поступлении'}
        else
          new_client = Client.create(email: params[:client_email])
          product = Product.find_or_create_by(insid: params[:product_id]) #добавка после расширения функционала
          variant = product.variants.find_or_create_by(insid: params[:variant_id])
          new_client.restocks.create(variant_id: variant.id) #добавка после расширения функционала
          render json: { success: true, message: 'Информация сохранена. Мы известим вас о поступлении' }
        end
      else
        render json: { error: false, message: 'Кол-во клиентов больше допустимого, товары не добавляются' }
      end
    end
  end

  def order
    number = params["number"]
    account_id = params["account_id"]
    puts "account_id => "+account_id.to_s

    insint = Insint.find_by_insales_account_id(account_id)
    saved_subdomain = insint.inskey.present? ? insint.user.subdomain : 'insales' + insint.insales_account_id.to_s
    Apartment::Tenant.switch(saved_subdomain) do
      if MessageSetup.check_ability
        client = Client.find_by_clientid(params["client"]["id"])
        if client.present?
          client.order_status_changes.create(client_id: client.id,insales_order_id: params["id"], insales_order_number: params["number"], insales_custom_status_title: params["custom_status"]["title"],insales_financial_status: params["financial_status"])
          render json: { success: true, message: 'Информация сохранена в order_status_changes'}
        else
          new_client = Client.create!(clientid: params["client"]["id"], email: params["client"]["email"], name: params["client"]["name"], phone: params["client"]["phone"])
          new_client.order_status_changes.create(client_id: new_client.id,insales_order_id: params["id"], insales_order_number: params["number"], insales_custom_status_title: params["custom_status"]["title"],insales_financial_status: params["financial_status"])
          render json: { success: true, message: 'Информация сохранена в order_status_changes' }
        end
      else
        render json: { error: false, message: 'не смогли добавить запись в order_status_changes' }
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
    params.require(:insint).permit(:subdomen, :password, :insales_account_id, :user_id, :inskey, :status)
  end
end
