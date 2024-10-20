#  encoding : utf-8
class InsintsController < ApplicationController
  before_action :authenticate_user!, except: %i[install uninstall login addizb getizb deleteizb emailizb order abandoned_cart restock preorder extra_data]
  before_action :authenticate_admin!, only: %i[adminindex]
  before_action :set_insint, only: %i[show edit update check destroy]

  def index
    @insints = current_user.insints if !current_admin
  end

  def adminindex
    @search = Insint.ransack(params[:q])
    @search.sorts = "id desc" if @search.sorts.empty?
    @insints = @search.result.paginate(page: params[:page], per_page: 30)
  end

  def show
    redirect_to useraccounts_url, alert: "Access denied." unless @insint.user == current_use
  end

  def new
    if current_user.insints.count == 0
      @insint = Insint.new
    else
      redirect_to dashboard_url, notice: "\u0423 \u0412\u0430\u0441 \u0443\u0436\u0435 \u0435\u0441\u0442\u044C \u0438\u043D\u0442\u0435\u0433\u0440\u0430\u0446\u0438\u044F"
    end
  end

  def edit
    redirect_to dashboard_url, alert: "Access denied." unless @insint.user == current_user || current_user.admin?
  end

  def create
    @insint = Insint.new(insint_params)
    respond_to do |format|
      if @insint.save
        service = ApiInsales.new(@insint)
        if service.work?
          @insint.update!(status: true, insales_account_id: service.account.id)
        else
          @insint.update!(status: false)
        end
        # @insint.update_and_email if service.work?
        notice = (service.work? == true) ? "\u0418\u043D\u0442\u0435\u0433\u0440\u0430\u0446\u0438\u044F insales \u0441\u043E\u0437\u0434\u0430\u043D\u0430. \u0418\u043D\u0442\u0435\u0433\u0440\u0430\u0446\u0438\u044F \u0440\u0430\u0431\u043E\u0442\u0430\u0435\u0442!" : "\u0418\u043D\u0442\u0435\u0433\u0440\u0430\u0446\u0438\u044F insales \u0441\u043E\u0437\u0434\u0430\u043D\u0430. \u041D\u0435 \u0440\u0430\u0431\u043E\u0442\u0430\u0435\u0442!"
        format.html { redirect_to dashboard_url, notice: notice }
        format.json { render :show, status: :created, location: @insint }
      else
        format.html { render :new, status: :unprocessable_entity }
        format.json { render json: @insint.errors, status: :unprocessable_entity }
      end
    end
  end

  def update
    respond_to do |format|
      if @insint.update(insint_params)
        service = ApiInsales.new(@insint)
        service.work? ? @insint.update!(status: true) : @insint.update!(status: false)
        notice = (service.work? == true) ? "\u0418\u043D\u0442\u0435\u0433\u0440\u0430\u0446\u0438\u044F insales \u043E\u0431\u043D\u043E\u0432\u043B\u0435\u043D\u0430. \u0418\u043D\u0442\u0435\u0433\u0440\u0430\u0446\u0438\u044F \u0440\u0430\u0431\u043E\u0442\u0430\u0435\u0442!" : "\u0418\u043D\u0442\u0435\u0433\u0440\u0430\u0446\u0438\u044F insales \u043E\u0431\u043D\u043E\u0432\u043B\u0435\u043D\u0430. \u041D\u0435 \u0440\u0430\u0431\u043E\u0442\u0430\u0435\u0442!"
        redirect_path = current_admin ? adminindex_insints_url : insints_url
        format.html { redirect_to redirect_path, notice: notice }
        format.json { render :show, status: :ok, location: @insint }
      else
        format.html { render :edit, notice: "\u041F\u0440\u043E\u0432\u0435\u0440\u044C\u0442\u0435 \u0434\u0430\u043D\u043D\u044B\u0435, \u0438\u043D\u0442\u0435\u0433\u0440\u0430\u0446\u0438\u044F \u043D\u0435 \u0440\u0430\u0431\u043E\u0442\u0430\u0435\u0442" }
        format.json { render json: @insint.errors, status: :unprocessable_entity }
      end
    end
  end

  def destroy
    @insint.destroy
    respond_to do |format|
      format.html { redirect_to insints_url, notice: "Insint was successfully destroyed." }
      format.json { head :no_content }
    end
  end

  def install
    # puts params[:insales_id]
    @insint = Insint.find_by_insales_account_id(params[:insales_id])
    if @insint.present?
      puts "\u0435\u0441\u0442\u044C \u03B2\u03C5\u03BD\u03C4\u03B8\u03B7\u03C6\u03C2\u03B2\u03B6 insint"
    else
      save_subdomain = "insales" + params[:insales_id]
      email = save_subdomain + "@mail.ru"
      # puts save_subdomain
      user = User.create(name: params[:insales_id], subdomain: save_subdomain, password: save_subdomain,
        password_confirmation: save_subdomain, email: email, valid_from: Date.today, valid_until: "Sat, 30 Dec 2024")
      secret_key = ENV["INS_APP_SECRET_KEY"]
      password = Digest::MD5.hexdigest(params[:token] + secret_key)
      Insint.create(subdomen: params[:shop], password: password, insales_account_id: params[:insales_id], user_id: user.id, status: true, inskey: "k-comment")
      head :ok
    end
  end

  def uninstall
    @insint = Insint.find_by_insales_account_id(params[:insales_id])
    saved_subdomain = "insales" + params[:insales_id]
    @user = User.find_by_subdomain(saved_subdomain)
    if @insint.present?
      Insint.delete_ins_file(@insint.id)
      puts "\u0443\u0434\u0430\u043B\u044F\u0435\u043C \u043F\u043E\u043B\u044C\u0437\u043E\u0432\u0430\u0442\u0435\u043B\u044F insint - ""#{@insint.id}"
      @insint.delete
      @user.delete
      Apartment::Tenant.drop(saved_subdomain)
      head :ok
    end
  end

  def login
    saved_subdomain = "insales" + params[:insales_id]
    user = User.find_by_subdomain(saved_subdomain)
    insint = user.insints.first
    if user.present? && insint.present?
      Apartment::Tenant.switch(saved_subdomain) do
        user_account = Useraccount.find_by_insuserid(params[:user_id])
        user_name = params[:user_id] + params[:shop]
        # Useraccount.create(shop: params[:shop], email: params[:user_email], insuserid: params[:user_id], name: user_name) if !user_account.present?
        Useraccount.create(shop: params[:shop], email: params[:user_email], name: user_name) if !user_account.present?
      end
      sign_in(:user, user)
      redirect_to after_sign_in_path_for(user), allow_other_host: true
    end
  end

  def addizb
    # это переход с хоста на аккаунт ид
    if params[:insales_account_id].present?
      insint = Insint.find_by_insales_account_id(params["insales_account_id"])
      saved_subdomain = insint.user.subdomain
    else
      insint = Insint.find_by_subdomen(params[:host])
      saved_subdomain = insint.inskey.present? ? insint.user.subdomain : "insales" + insint.insales_account_id.to_s
    end

    Apartment::Tenant.switch(saved_subdomain) do
      if MessageSetup.check_ability
        pr_id = params[:product_id]
        client_id = params[:client_id]
        client = Client.find_by_clientid(client_id)
        product = Product.find_by(insid: pr_id).present? ? Product.find_by(insid: pr_id) : Product.create!(insid: pr_id)

        if client.present?
          fav = Favorite.new(product_id: product.id, client_id: client.id, created_at: Time.now, updated_at: Time.now)
          fav.save
          totalcount = client.favorites.uniq.count.to_s
          render json: {success: true, message: "\u0442\u043E\u0432\u0430\u0440 \u0434\u043E\u0431\u0430\u0432\u043B\u0435\u043D \u0432 \u0438\u0437\u0431\u0440\u0430\u043D\u043D\u043E\u0435", totalcount: totalcount}
        else
          service = ApiInsales.new(insint)
          api_client = service.client(client_id)
          new_client_data = {
            clientid: params[:client_id],
            name: search_client.name,
            surname: search_client.surname,
            email: search_client.email,
            phone: search_client.phone
          }
          check_client_from_api = Client.find_by_email(api_client.email)
          check_client_from_api.update!(new_client_data) if check_client_from_api
          client = check_client_from_api.present? ? check_client_from_api : Client.create!(new_client_data)
          fav = Favorite.new(product_id: product.id, client_id: client.id, created_at: Time.now, updated_at: Time.now)
          fav.save
          totalcount = new_client.favorites.uniq.count.to_s
          render json: {success: true, message: "\u0442\u043E\u0432\u0430\u0440 \u0434\u043E\u0431\u0430\u0432\u043B\u0435\u043D \u0432 \u0438\u0437\u0431\u0440\u0430\u043D\u043D\u043E\u0435", totalcount: totalcount}
        end
      else
        render json: {error: false, message: "\u041A\u043E\u043B-\u0432\u043E \u043A\u043B\u0438\u0435\u043D\u0442\u043E\u0432 \u0431\u043E\u043B\u044C\u0448\u0435 \u0434\u043E\u043F\u0443\u0441\u0442\u0438\u043C\u043E\u0433\u043E, \u0442\u043E\u0432\u0430\u0440\u044B \u043D\u0435 \u0434\u043E\u0431\u0430\u0432\u043B\u044F\u044E\u0442\u0441\u044F"}
      end
    end
  end

  def getizb
    # это переход с хоста на аккаунт ид
    if params[:insales_account_id].present?
      insint = Insint.find_by_insales_account_id(params["insales_account_id"])
      saved_subdomain = insint.user.subdomain
    else
      insint = Insint.find_by_subdomen(params[:host])
      saved_subdomain = insint.inskey.present? ? insint.user.subdomain : "insales" + insint.insales_account_id.to_s
    end

    Apartment::Tenant.switch(saved_subdomain) do
      client = Client.find_by_clientid(params[:client_id])
      if client.present?
        favorite_product_ids = client.favorites.pluck(:product_id).uniq.reverse
        ins_ids = Product.where(id: favorite_product_ids).pluck(:insid).join(",")
        totalcount = favorite_product_ids.count.to_s
        render json: {success: true, products: ins_ids, totalcount: totalcount}
      else
        render json: {error: false, message: "\u043D\u0435\u0442 \u0442\u0430\u043A\u043E\u0433\u043E \u043A\u043B\u0438\u0435\u043D\u0442\u0430"}
      end
    end
  end

  def deleteizb
    # это переход с хоста на аккаунт ид
    if params[:insales_account_id].present?
      insint = Insint.find_by_insales_account_id(params["insales_account_id"])
      saved_subdomain = insint.user.subdomain
    else
      insint = Insint.find_by_subdomen(params[:host])
      saved_subdomain = insint.inskey.present? ? insint.user.subdomain : "insales" + insint.insales_account_id.to_s
    end

    Apartment::Tenant.switch(saved_subdomain) do
      # if FavoriteSetup.check_ability - we have now only one service
      if MessageSetup.check_ability
        client = Client.find_by_clientid(params[:client_id])
        if client.present?
          # добавка после расширения функционала
          product = Product.find_by_insid(params[:product_id])
          favorite = client.favorites.find_by_product_id(product.id)
          favorite.destroy if product.present? && favorite.present?
          totalcount = client.favorites.uniq.count.to_s
          render json: {success: true, message: "\u0442\u043E\u0432\u0430\u0440 \u0443\u0434\u0430\u043B\u0451\u043D", totalcount: totalcount}
        end
      else
        render json: {success: true, message: "Кол-во клиентов больше допустимого, товары не удаляются"}
      end
    end
  end

  def emailizb
    insint = Insint.find_by_subdomen(params[:host])
    saved_subdomain = insint.inskey.present? ? insint.user.subdomain : "insales" + insint.insales_account_id.to_s
    if saved_subdomain != "insales753667" # saved_subdomain != "mamamila" ||
      Apartment::Tenant.switch(saved_subdomain) do
        # if FavoriteSetup.check_ability - we have now only one service
        if MessageSetup.check_ability
          client = Client.find_by_clientid(params[:client_id])
          if client.present?
            Client.emailizb(saved_subdomain, client.id, insint.user.id)
            render json: {success: true, message: "\u0422\u043E\u0432\u0430\u0440\u044B \u043E\u0442\u043F\u0440\u0430\u0432\u043B\u0435\u043D\u044B \u0412\u0430\u043C \u043D\u0430 \u043F\u043E\u0447\u0442\u0443"}
          else
            render json: {error: false, message: "\u043D\u0435\u0442 \u0442\u0430\u043A\u043E\u0433\u043E \u043A\u043B\u0438\u0435\u043D\u0442\u0430"}
          end
        else
          render json: {error: false, message: "Кол-во клиентов больше допустимого, письма не отправляются"}
        end
      end
    else
      render json: {error: false, message: "\u0421\u0435\u0440\u0432\u0438\u0441 \u0418\u0437\u0431\u0440\u0430\u043D\u043D\u043E\u0435 \u043D\u0435 \u043E\u043F\u043B\u0430\u0447\u0435\u043D. \u041F\u0440\u0438\u043D\u043E\u0441\u0438\u043C \u0441\u0432\u043E\u0438 \u0438\u0437\u0432\u0438\u043D\u0435\u043D\u0438\u044F. \u0412\u0430\u0448\u0430 \u0438\u0441\u0442\u043E\u0440\u0438\u044F \u043D\u0435 \u0438\u0441\u0447\u0435\u0437\u043B\u0430."}
    end
  end

  def check
    @insint = Insint.find(params[:id])
    service = ApiInsales.new(@insint)
    notice = (service.work? == true) ? "\u0418\u043D\u0442\u0435\u0433\u0440\u0430\u0446\u0438\u044F \u0440\u0430\u0431\u043E\u0442\u0430\u0435\u0442!" : "\u041D\u0435 \u0440\u0430\u0431\u043E\u0442\u0430\u0435\u0442 \u0438\u043D\u0442\u0435\u0433\u0440\u0430\u0446\u0438\u044F!"
    respond_to do |format|
      flash.now[:success] = notice
      format.turbo_stream do
        render turbo_stream: [
          render_turbo_flash
        ]
      end
    end
  end

  def order
    number = params["number"]
    account_id = params["account_id"]
    puts "insint order account_id => " + account_id.to_s

    insint = Insint.find_by_insales_account_id(account_id)
    saved_subdomain = insint.user.subdomain
    Apartment::Tenant.switch(saved_subdomain) do
      if MessageSetup.check_ability
        InsintOrderJob.perform_later(saved_subdomain, params.permit!)
        render json: {success: true, message: "\u0418\u043D\u0444\u043E\u0440\u043C\u0430\u0446\u0438\u044F \u0441\u043E\u0445\u0440\u0430\u043D\u0435\u043D\u0430 \u0432 order_status_changes and case"}
      else
        render json: {error: false, message: "\u043D\u0435 \u0441\u043C\u043E\u0433\u043B\u0438 \u0434\u043E\u0431\u0430\u0432\u0438\u0442\u044C \u0437\u0430\u043F\u0438\u0441\u044C \u0432 order_status_changes and case \u0421\u0435\u0440\u0432\u0438\u0441 \u043D\u0435 \u0432\u043A\u043B\u044E\u0447\u0435\u043D"}
      end
    end
  end

  def abandoned_cart
    number = params["id"]
    account_id = params["insales_account_id"]
    puts "account_id => #{account_id}"

    insint = Insint.find_by_insales_account_id(account_id)
    saved_subdomain = insint.user.subdomain
    Apartment::Tenant.switch(saved_subdomain) do
      if MessageSetup.check_ability && params["lines"].presence && params["contacts"]["email"].presence
        number = params["id"]
        email = params["contacts"]["email"]
        phone = params["contacts"]["phone"]
        name = params["contacts"]["name"].present? ? params["contacts"]["name"] : "abandoned_#{number}"
        search_client = Client.find_by_email(email).present? ? Client.find_by_email(email) : Client.find_by_phone(phone)

        client = search_client.present? ? search_client : Client.create!(email: email, phone: phone, name: name)
        search_mycase = Mycase.find_by_number(number)
        mycase = search_mycase.present? ? search_mycase : Mycase.create!(number: number, casetype: "abandoned_cart", client_id: client.id, status: "new")

        puts "insint abandoned_cart mycase => " + mycase.inspect.to_s

        mycase.lines.delete_all # this we need to have last cart data if user change cart after several time

        params["lines"].each do |o_line|
          product = Product.find_by_insid(o_line["productId"].to_i).present? ? Product.find_by_insid(o_line["productId"].to_i) :
                                                                        Product.create!(insid: o_line["productId"].to_i)
          variant = product.variants.where(insid: o_line["variantId"].to_i).present? ? product.variants.where(insid: o_line["variantId"].to_i)[0] :
                                                                                  product.variants.create!(insid: o_line["variantId"].to_i)

          line = mycase.lines.where(product_id: product.id, variant_id: variant.id)
          line_data = {
            product_id: product.id,
            variant_id: variant.id,
            quantity: o_line["quantity"],
            price: o_line["full_total_price"]
          }

          line.present? ? line.first.update!(line_data) : mycase.lines.create!(line_data)
        end
        
        mycase.add_abandoned_cart
        mycase.do_event_action if !search_mycase.present?

        render json: {success: true, message: "\u0418\u043D\u0444\u043E\u0440\u043C\u0430\u0446\u0438\u044F \u0441\u043E\u0445\u0440\u0430\u043D\u0435\u043D\u0430 \u0432 cases abandoned_cart"}
      else
        render json: {error: true, message: "\u043D\u0435 \u0441\u043C\u043E\u0433\u043B\u0438 \u0434\u043E\u0431\u0430\u0432\u0438\u0442\u044C \u0437\u0430\u043F\u0438\u0441\u044C \u0432 cases abandoned_cart \u0421\u0435\u0440\u0432\u0438\u0441 \u043D\u0435 \u0432\u043A\u043B\u044E\u0447\u0435\u043D"}
      end
    end
  end

  def restock
    number = params["id"]
    account_id = params["insales_account_id"]
    puts "account_id => " + account_id.to_s

    insint = Insint.find_by_insales_account_id(account_id)
    saved_subdomain = insint.user.subdomain
    Apartment::Tenant.switch(saved_subdomain) do
      if MessageSetup.check_ability
        number = params["id"]
        search_client = Client.find_by_email(params["contacts"]["email"]).present? ? Client.find_by_email(params["contacts"]["email"]) :
                                                                                    Client.find_by_phone(params["contacts"]["phone"])
        client_name = params["contacts"]["name"].present? ? params["contacts"]["name"] : "restock_" + number.to_s
        phone = params["contacts"]["phone"].present? ? params["contacts"]["phone"] : "+79011111111"
        client = search_client.present? ? search_client : Client.create!(email: params["contacts"]["email"], phone: phone, name: client_name)
        mycase = Mycase.find_by_number(number).present? ? Mycase.find_by_number(number) :
                                                      Mycase.create!(number: number, casetype: "restock", client_id: client.id, status: "new")
        puts "insint restock mycase => " + mycase.to_s
        params["lines"].each do |o_line|
          product = Product.find_by_insid(o_line["productId"]).present? ? Product.find_by_insid(o_line["productId"]) :
                                                                        Product.create!(insid: o_line["productId"])
          variant = product.variants.where(insid: o_line["variantId"]).present? ? product.variants.where(insid: o_line["variantId"])[0] :
                                                                                product.variants.create!(insid: o_line["variantId"])

          line = mycase.lines.where(product_id: product.id, variant_id: variant.id)
          if line.present?
            line.first.update!(quantity: o_line["quantity"], price: o_line["full_total_price"])
          else
            mycase.lines.create!(product_id: product.id, variant_id: variant.id, quantity: o_line["quantity"], price: o_line["full_total_price"])
          end
        end
        mycase.add_restock

        render json: {success: true, message: "\u0418\u043D\u0444\u043E\u0440\u043C\u0430\u0446\u0438\u044F \u0441\u043E\u0445\u0440\u0430\u043D\u0435\u043D\u0430 \u0432 cases restock"}
      else
        render json: {error: true, message: "\u043D\u0435 \u0441\u043C\u043E\u0433\u043B\u0438 \u0434\u043E\u0431\u0430\u0432\u0438\u0442\u044C \u0437\u0430\u043F\u0438\u0441\u044C \u0432 cases restock \u0421\u0435\u0440\u0432\u0438\u0441 \u043D\u0435 \u0432\u043A\u043B\u044E\u0447\u0435\u043D"}
      end
    end
  end

  def preorder
    number = params["id"]
    account_id = params["insales_account_id"]
    puts "account_id => " + account_id.to_s

    insint = Insint.find_by_insales_account_id(account_id)
    saved_subdomain = insint.user.subdomain
    Apartment::Tenant.switch(saved_subdomain) do
      if MessageSetup.check_ability
        number = params["id"]
        search_client = Client.find_by_email(params["contacts"]["email"]).present? ? Client.find_by_email(params["contacts"]["email"]) :
                                                                                    Client.find_by_phone(params["contacts"]["phone"])
        client_name = params["contacts"]["name"].present? ? params["contacts"]["name"] : "preorder_" + number.to_s
        phone = params["contacts"]["phone"].present? ? params["contacts"]["phone"] : "+79011111111"
        client = search_client.present? ? search_client : Client.create!(email: params["contacts"]["email"], phone: phone, name: client_name)
        mycase = Mycase.find_by_number(number).present? ? Mycase.find_by_number(number) :
                                                      Mycase.create!(number: number, casetype: "preorder", client_id: client.id, status: "new")
        puts "insint preorder mycase => " + mycase.to_s
        params["lines"].each do |o_line|
          product = Product.find_by_insid(o_line["productId"]).present? ? Product.find_by_insid(o_line["productId"]) :
                                                                        Product.create!(insid: o_line["productId"])
          variant = product.variants.where(insid: o_line["variantId"]).present? ? product.variants.where(insid: o_line["variantId"])[0] :
                                                                                product.variants.create!(insid: o_line["variantId"])
          line = mycase.lines.where(product_id: product.id, variant_id: variant.id)
          if line.present?
            line.first.update!(quantity: o_line["quantity"], price: o_line["full_total_price"])
          else
            mycase.lines.create!(product_id: product.id, variant_id: variant.id, quantity: o_line["quantity"], price: o_line["full_total_price"])
          end
        end
        mycase.add_preorder
        mycase.do_event_action

        render json: {success: true, message: "\u0418\u043D\u0444\u043E\u0440\u043C\u0430\u0446\u0438\u044F \u0441\u043E\u0445\u0440\u0430\u043D\u0435\u043D\u0430 \u0432 cases preorder"}
      else
        render json: {error: false, message: "\u043D\u0435 \u0441\u043C\u043E\u0433\u043B\u0438 \u0434\u043E\u0431\u0430\u0432\u0438\u0442\u044C \u0437\u0430\u043F\u0438\u0441\u044C \u0432 cases preorder \u0421\u0435\u0440\u0432\u0438\u0441 \u043D\u0435 \u0432\u043A\u043B\u044E\u0447\u0435\u043D"}
      end
    end
  end

  def extra_data
    data = {
      discount: 111,
      discount_type: "MONEY",
      title: "Ваша пошлина за заказ"
    }

    # render json: { success: true, data: data}
    render json: data
  end

  private

  def set_insint
    @insint = Insint.find(params[:id])
  end

  def insint_params
    params.require(:insint).permit(:subdomen, :password, :insales_account_id, :user_id, :inskey, :status)
  end
end
