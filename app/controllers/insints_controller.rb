class InsintsController < ApplicationController
  before_action :authenticate_user!, except: %i[install uninstall login addizb getizb deleteizb emailizb order abandoned_cart restock preorder extra_data]
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
    redirect_to dashboard_url, alert: 'Access denied.' unless @insint.user == current_user || current_user.admin?
  end

  # POST /insints
  def create
    @insint = Insint.new(insint_params)
    respond_to do |format|
      if @insint.save
        service = ApiInsales.new(@insint)
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
          service = ApiInsales.new(@insint)
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
      redirect_to after_sign_in_path_for(user), allow_other_host: true
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
            product = Product.find_by(insid: params[:product_id]).present? ? Product.find_by(insid: params[:product_id]) : Product.create!(insid: params[:product_id])
            fav = Favorite.new(product_id: product.id, client_id: client.id, created_at: Time.now, updated_at: Time.now)
            fav.save
            totalcount = client.favorites.uniq.count.to_s
            # product.get_ins_api_data
            #конец добавка после расширения функционала
            render json: { success: true, message: 'товар добавлен в избранное', totalcount: totalcount }
          else
            service = ApiInsales.new(insint)
            search_client = service.client(params[:client_id])
            new_client_data = {
              clientid: params[:client_id],
              name: search_client.name,
              surname: search_client.surname,
              email: search_client.email,
              phone: search_client.phone
            }
            # puts "new_client_data => "+new_client_data.to_s
            new_client = Client.create!(new_client_data)
            # totalcount = new_client.izb_productid.split(',').count
            #добавка после расширения функционала
            product = Product.find_by(insid: params[:product_id]).present? ? Product.find_by(insid: params[:product_id]) : Product.create!(insid: params[:product_id])
            fav = Favorite.new(product_id: product.id, client_id: new_client.id, created_at: Time.now, updated_at: Time.now)
            fav.save
            totalcount = new_client.favorites.uniq.count.to_s
            # product.get_ins_api_data
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
            favorite_product_ids = client.favorites.pluck(:product_id).uniq.reverse
            ins_ids = client.products.where(id: favorite_product_ids).pluck(:insid).join(',')
            totalcount = favorite_product_ids.count.to_s
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
            client.favorites.find_by_product_id(product.id).destroy if product.present? #добавка после расширения функционала
            totalcount = client.favorites.uniq.count.to_s
            render json: { success: true, message: 'товар удалён', totalcount: totalcount }
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
    service = ApiInsales.new(@insint)
    notice = service.work? == true ? 'Интеграция работает!' : 'Не работает интеграция!'
    respond_to do |format|
      format.js do
        flash.now[:notice] = notice
      end
    end
  end

  def order
    number = params["number"]
    account_id = params["account_id"]
    puts "insint order account_id => "+account_id.to_s

    insint = Insint.find_by_insales_account_id(account_id)
    saved_subdomain = insint.user.subdomain
    Apartment::Tenant.switch(saved_subdomain) do
      if MessageSetup.check_ability
        #check_client = Client.find_by_clientid(params["client"]["id"])
        check_client = Client.find_by_email(params["client"]["email"])
        client_data = {
                        clientid: params["client"]["id"], 
                        email: params["client"]["email"], 
                        name: params["client"]["name"], 
                        phone: params["client"]["phone"]
                      }
        check_client.update!(client_data) if check_client.present?
        client = check_client.present? ? check_client : Client.create!(client_data)

        # создаём запись о том что произошло изменение в заказе
        client.order_status_changes.create!(  insales_order_id: params["id"], 
                                              insales_order_number: params["number"], 
                                              insales_custom_status_title: params["custom_status"]["title"],
                                              insales_financial_status: params["financial_status"])
        # конец запись о том что произошло изменение в заказе
        # проверяем заявку и создаём или обновляем
        search_case = Case.where(client_id: client.id, insales_order_id: params["id"])
        puts "search_case.id => "+search_case.first.id.to_s if search_case.present?
        mycase = search_case.present? ? search_case.update( insales_custom_status_title: params["custom_status"]["title"], 
                                                                  insales_financial_status: params["financial_status"],
                                                                  status: "take")[0] : 
                                        Case.create!( client_id: client.id, insales_order_id: params["id"], 
                                                      insales_custom_status_title: params["custom_status"]["title"],
                                                      insales_financial_status: params["financial_status"],
                                                      status: "new", casetype: "order", number: params["number"] )
        puts "mycase => "+mycase.to_s
        puts mycase.is_a?Array
        params["order_lines"].each do |o_line|
          product = Product.find_by_insid(o_line["product_id"]).present? ?  Product.find_by_insid(o_line["product_id"]) : 
                                                                          Product.create!(insid: o_line["product_id"])
          puts "insint order product => "+product.inspect
          variant = product.variants.where(insid: o_line["variant_id"]).present? ? product.variants.where(insid: o_line["variant_id"])[0] : 
                                                                                product.variants.create!(insid: o_line["variant_id"])
          line = mycase.lines.where(product_id: product.id, variant_id: variant.id)
          if line.present?
            line.first.update!(quantity: o_line["quantity"], price: o_line["full_total_price"])
          else
            mycase.lines.create!( product_id: product.id, variant_id: variant.id, quantity: o_line["quantity"], price: o_line["full_total_price"])
          end

        end

        # конец проверяем заявку и создаём или обновляем

        mycase.do_event_action
        # конец создаём заявку
        render json: { success: true, message: 'Информация сохранена в order_status_changes and case' }
      else
        render json: { error: false, message: 'не смогли добавить запись в order_status_changes and case Сервис не включен' }
      end
    end
  end

  def abandoned_cart
    number = params["id"]
    account_id = params["insales_account_id"]
    puts "account_id => "+account_id.to_s

    insint = Insint.find_by_insales_account_id(account_id)
    # insint = Insint.find_by_insales_account_id(784184)
    saved_subdomain = insint.user.subdomain
    Apartment::Tenant.switch(saved_subdomain) do
      # if MessageSetup.check_ability && params["lines"].presence
        number = params["id"]
        search_client = Client.find_by_email(params["contacts"]["email"]).present? ?  Client.find_by_email(params["contacts"]["email"]) : 
                                                                                      Client.find_by_phone(params["contacts"]["phone"])
        
        client = search_client.present? ? search_client : 
                                          Client.create!( email: params["contacts"]["email"], phone: params["contacts"]["phone"], 
                                                                                              name: "abandoned_"+number.to_s)
        mycase = Case.find_by_number(number).present? ? Case.find_by_number(number) : 
                                                        Case.create!( number: number, casetype: 'abandoned_cart', client_id: client.id, status: "new")
        puts "insint abandoned_cart mycase => "+mycase.inspect.to_s
        params["lines"].each do |o_line|
          product = Product.find_by_insid(o_line["productId"].to_i).present? ? Product.find_by_insid(o_line["productId"].to_i) : 
                                                                        Product.create!(insid: o_line["productId"].to_i)
          variant = product.variants.where(insid: o_line["variantId"].to_i).present? ? product.variants.where(insid: o_line["variantId"].to_i)[0] : 
                                                                                  product.variants.create!(insid: o_line["variantId"].to_i)
          # mycase.lines.create!(  product_id: product.id, variant_id: variant.id, quantity: o_line["quantity"], price: o_line["price"])
          line = mycase.lines.where(product_id: product.id, variant_id: variant.id)
          if line.present?
            line.first.update!(quantity: o_line["quantity"], price: o_line["full_total_price"])
          else
            mycase.lines.create!( product_id: product.id, variant_id: variant.id, quantity: o_line["quantity"], price: o_line["full_total_price"])
          end
        
        end
        mycase.do_event_action
        render json: { success: true, message: 'Информация сохранена в cases abandoned_cart'}
      # else
      #   render json: { error: true, message: 'не смогли добавить запись в cases abandoned_cart Сервис не включен' }
      end
    # end
  end

  def restock
    number = params["id"]
    account_id = params["insales_account_id"]
    puts "account_id => "+account_id.to_s

    insint = Insint.find_by_insales_account_id(account_id)
    # insint = Insint.find_by_insales_account_id(784184)
    saved_subdomain = insint.user.subdomain
    Apartment::Tenant.switch(saved_subdomain) do
      if MessageSetup.check_ability
        number = params["id"]
        search_client = Client.find_by_email(params["contacts"]["email"]).present? ? Client.find_by_email(params["contacts"]["email"]) : 
                                                                                    Client.find_by_phone(params["contacts"]["phone"])
        client_name = params["contacts"]["name"].present? ? params["contacts"]["name"] : "restock_"+number.to_s
        phone = params["contacts"]["phone"].present? ? params["contacts"]["phone"] : "+79011111111"
        client = search_client.present? ? search_client : Client.create!( email: params["contacts"]["email"], phone: phone, name: client_name)
        mycase = Case.find_by_number(number).present? ? Case.find_by_number(number) : 
                                                      Case.create!(number: number, casetype: 'restock', client_id: client.id, status: "new")
        puts "insint restock mycase => "+mycase.to_s
        params["lines"].each do |o_line|
          product = Product.find_by_insid(o_line["productId"]).present? ? Product.find_by_insid(o_line["productId"]) : 
                                                                        Product.create!(insid: o_line["productId"])
          variant = product.variants.where(insid: o_line["variantId"]).present? ? product.variants.where(insid: o_line["variantId"])[0] : 
                                                                                product.variants.create!(insid: o_line["variantId"])

          # our_line = mycase.lines.create!(  product_id: product.id, variant_id: variant.id, quantity: o_line["quantity"], price: o_line["price"])

          line = mycase.lines.where(product_id: product.id, variant_id: variant.id)
          if line.present?
            line.first.update!(quantity: o_line["quantity"], price: o_line["full_total_price"])
          else
            mycase.lines.create!( product_id: product.id, variant_id: variant.id, quantity: o_line["quantity"], price: o_line["full_total_price"])
          end
                                                                              
        end
        mycase.add_restock

        render json: { success: true, message: 'Информация сохранена в cases restock'}
      else
        render json: { error: true, message: 'не смогли добавить запись в cases restock Сервис не включен' }
      end
    end
  end

  def preorder
    number = params["id"]
    account_id = params["insales_account_id"]
    puts "account_id => "+account_id.to_s

    insint = Insint.find_by_insales_account_id(account_id)
    # insint = Insint.find_by_insales_account_id(784184)
    saved_subdomain = insint.user.subdomain
    Apartment::Tenant.switch(saved_subdomain) do
      if MessageSetup.check_ability
        number = params["id"]
        search_client = Client.find_by_email(params["contacts"]["email"]).present? ? Client.find_by_email(params["contacts"]["email"]) : 
                                                                                    Client.find_by_phone(params["contacts"]["phone"])
        client_name = params["contacts"]["name"].present? ? params["contacts"]["name"] : "preorder_"+number.to_s
        phone = params["contacts"]["phone"].present? ? params["contacts"]["phone"] : "+79011111111"
        client = search_client.present? ? search_client : Client.create!( email: params["contacts"]["email"], phone: phone, name: client_name)
        mycase = Case.find_by_number(number).present? ? Case.find_by_number(number) : 
                                                      Case.create!(number: number, casetype: 'preorder', client_id: client.id, status: "new")
        puts "insint preorder mycase => "+mycase.to_s
        params["lines"].each do |o_line|
          product = Product.find_by_insid(o_line["productId"]).present? ? Product.find_by_insid(o_line["productId"]) : 
                                                                        Product.create!(insid: o_line["productId"])
          variant = product.variants.where(insid: o_line["variantId"]).present? ? product.variants.where(insid: o_line["variantId"])[0] : 
                                                                                product.variants.create!(insid: o_line["variantId"])
          # our_line = mycase.lines.create!(  product_id: product.id, variant_id: variant.id, quantity: o_line["quantity"], price: o_line["price"])

          line = mycase.lines.where(product_id: product.id, variant_id: variant.id)
          if line.present?
            line.first.update!(quantity: o_line["quantity"], price: o_line["full_total_price"])
          else
            mycase.lines.create!( product_id: product.id, variant_id: variant.id, quantity: o_line["quantity"], price: o_line["full_total_price"])
          end

        end
        mycase.add_preorder

        render json: { success: true, message: 'Информация сохранена в cases preorder'}
      else
        render json: { error: false, message: 'не смогли добавить запись в cases preorder Сервис не включен' }
      end
    end
  end

  def extra_data
    data = {
      "discount": 111,
      "discount_type": "MONEY",
      "title": "Ваша пошлина за заказ"
      }

      #render json: { success: true, data: data}
      render json: data
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
