#  encoding : utf-8
class InsintsController < ApplicationController
  before_action :authenticate_user!, except: %i[addizb getizb deleteizb emailizb order abandoned_cart restock preorder extra_data]
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
    redirect_to useraccounts_url, alert: 'Access denied.' unless @insint.user == current_use
  end

  def new
    if current_user.insints.count == 0
      @insint = Insint.new
    else
      redirect_to dashboard_url, notice: 'У Вас уже есть интеграция'
    end
  end

  def edit
    redirect_to dashboard_url, alert: 'Access denied.' unless @insint.user == current_user || current_user.admin?
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
        notice = (service.work? == true) ? 'Интеграция insales создана. Интеграция работает!' : 'Интеграция insales создана. Не работает!'
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
        notice = (service.work? == true) ? 'Update. Интеграция работает!' : 'Updateю Интеграция не работает!'
        redirect_path = current_admin ? adminindex_insints_url : insints_url
        format.html { redirect_to redirect_path, notice: notice }
        format.json { render :show, status: :ok, location: @insint }
      else
        format.html { render :edit, notice: 'Проверьте данные, интеграция не работает' }
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
    # # puts params[:insales_id]
    # @insint = Insint.find_by_insales_account_id(params[:insales_id])
    # if @insint.present?
    # else
    #   save_subdomain = "insales" + params[:insales_id]
    #   email = save_subdomain + "@mail.ru"
    #   # puts save_subdomain
    #   user = User.create(name: params[:insales_id], subdomain: save_subdomain, password: save_subdomain,
    #     password_confirmation: save_subdomain, email: email, valid_from: Date.today, valid_until: "Sat, 30 Dec 2024")
    #   secret_key = ENV['INS_APP_SECRET_KEY']
    #   password = Digest::MD5.hexdigest(params[:token] + secret_key)
    #   Insint.create(subdomen: params[:shop], password: password, insales_account_id: params[:insales_id], user_id: user.id, status: true, inskey: "k-comment")
    #   head :ok
    # end
    head :ok
  end

  def uninstall
    @insint = Insint.find_by_insales_account_id(params[:insales_id])
    saved_subdomain = "insales #{params[:insales_id]}"
    @user = User.find_by_subdomain(saved_subdomain)
    if @insint.present?
      Insint.delete_ins_file(@insint.id)
      puts "удаляем пользователя insint - #{@insint.id}"
      @insint.delete
      @user.delete
      Apartment::Tenant.drop(saved_subdomain)
      head :ok
    end
  end

  def login
    saved_subdomain = "insales #{params[:insales_id]}"
    user = User.find_by_subdomain(saved_subdomain)
    insint = user.insints.first
    if user.present? && insint.present?
      Apartment::Tenant.switch(saved_subdomain) do
        user_account = Useraccount.find_by_insuserid(params[:user_id])
        user_name = params[:user_id] + params[:shop]
        Useraccount.create(shop: params[:shop], email: params[:user_email], name: user_name) unless user_account.present?
      end
      sign_in(:user, user)
      redirect_to after_sign_in_path_for(user), allow_other_host: true
    end
  end

  def addizb
    # это переход с хоста на аккаунт ид
    if params[:insales_account_id].present?
      insint = Insint.find_by_insales_account_id(params['insales_account_id'])
      saved_subdomain = insint.user.subdomain
    else
      insint = Insint.find_by_subdomen(params[:host])
      saved_subdomain = insint.inskey.present? ? insint.user.subdomain : "insales #{insint.insales_account_id.to_s}"
    end

    Apartment::Tenant.switch(saved_subdomain) do
      if MessageSetup.check_ability
        pr_id = params[:product_id]
        client_id = params[:client_id]
        client = Client.find_by_clientid(client_id)
        product = Product.find_by(insid: pr_id).present? ? Product.find_by(insid: pr_id) : Product.create!(insid: pr_id)
        resp_data = {}
        # default
        resp_data['success'] = false
        resp_data['message'] = 'service not work'
        resp_data['totalcount'] = 0
        #
        if client.present?
          fav = Favorite.new(product_id: product.id, client_id: client.id, created_at: Time.now, updated_at: Time.now)
          fav.save
          fav_totalcount = client.favorites.uniq.count.to_s
          # render json: {success: true, message: 'товар добавлен в избранное', totalcount: totalcount}
          resp_data['success'] = true
          resp_data['message'] = 'товар добавлен в избранное'
          resp_data['totalcount'] = fav_totalcount
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
          fav_totalcount = new_client.favorites.uniq.count.to_s
          # render json: {success: true, message: 'товар добавлен в избранное', totalcount: totalcount}
          resp_data['success'] = true
          resp_data['message'] = 'товар добавлен в избранное'
          resp_data['totalcount'] = fav_totalcount
        end
      end
      render json: resp_data
    end
  end

  def getizb
    # это переход с хоста на аккаунт ид
    if params[:insales_account_id].present?
      insint = Insint.find_by_insales_account_id(params['insales_account_id'])
      saved_subdomain = insint.user.subdomain
    else
      insint = Insint.find_by_subdomen(params[:host])
      saved_subdomain = insint.inskey.present? ? insint.user.subdomain : "insales #{insint.insales_account_id}"
    end

    Apartment::Tenant.switch(saved_subdomain) do
      client = Client.find_by_clientid(params[:client_id])
      if client.present?
        favorite_product_ids = client.favorites.pluck(:product_id).uniq.reverse
        ins_ids = Product.where(id: favorite_product_ids).pluck(:insid).join(',')
        totalcount = favorite_product_ids.count.to_s
        render json: { success: true, products: ins_ids, totalcount: totalcount }
      else
        render json: { error: false, message: 'нет такого клиента' }
      end
    end
  end

  def deleteizb
    # это переход с хоста на аккаунт ид . у нас есть магазин где первый вариант 
    if params[:insales_account_id].present?
      insint = Insint.find_by_insales_account_id(params['insales_account_id'])
      saved_subdomain = insint.user.subdomain
    else
      insint = Insint.find_by_subdomen(params[:host])
      saved_subdomain = insint.inskey.present? ? insint.user.subdomain : "insales#{insint.insales_account_id}"
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
          render json: { success: true, message: 'товар удалён', totalcount: totalcount }
        end
      else
        render json: { success: true, message: 'Кол-во клиентов больше допустимого, товары не удаляются' }
      end
    end
  end

  def emailizb
    insint = Insint.find_by_subdomen(params[:host])
    saved_subdomain = insint.inskey.present? ? insint.user.subdomain : "insales #{insint.insales_account_id.to_s}"
    if saved_subdomain != "insales753667" # saved_subdomain != "mamamila" ||
      Apartment::Tenant.switch(saved_subdomain) do
        # if FavoriteSetup.check_ability - we have now only one service
        if MessageSetup.check_ability
          client = Client.find_by_clientid(params[:client_id])
          if client.present?
            Client.emailizb(saved_subdomain, client.id, insint.user.id)
            render json: {success: true, message: 'Товары отправлены Вам на почту'}
          else
            render json: {error: false, message: 'нет такого клиента'}
          end
        else
          render json: {error: false, message: "Кол-во клиентов больше допустимого, письма не отправляются"}
        end
      end
    else
      render json: {error: false, message: 'Сервис Избранное временно не работает. Приносим свои извинения. Ваша история не исчезла.'}
    end
  end

  def check
    @insint = Insint.find(params[:id])
    service = ApiInsales.new(@insint)
    notice = (service.work? == true) ? 'Интеграция работает!' : 'Не работает интеграция!'
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
    account_id = params['account_id']
    puts "insint order account_id => #{account_id}"

    insint = Insint.find_by_insales_account_id(account_id)
    saved_subdomain = insint.user.subdomain
    Apartment::Tenant.switch(saved_subdomain) do
      if MessageSetup.check_ability
        InsintOrderJob.perform_later(saved_subdomain, params.permit!)
        render json: {success: true, message: 'Информация сохранена в order_status_changes and case'}
      else
        render json: {error: false, message: 'не смогли добавить запись в order_status_changes and case Сервис не включен'}
      end
    end
  end

  def abandoned_cart
    account_id = params['insales_account_id']
    puts "account_id => #{account_id}"

    insint = Insint.find_by_insales_account_id(account_id)
    saved_subdomain = insint.user.subdomain
    Apartment::Tenant.switch(saved_subdomain) do
      if MessageSetup.check_ability && params['lines'].presence && params['contacts']['email'].presence
        InsintAbandonedCartJob.perform_later(saved_subdomain, params.permit!)
        render json: {success: true, message: 'Информация сохранена в cases abandoned_cart'}
      else
        render json: {error: true, message: 'не смогли добавить запись в cases abandoned_cart Сервис не включен'}
      end
    end
  end

  def restock
    account_id = params['insales_account_id']
    puts "account_id => #{account_id}"

    insint = Insint.find_by_insales_account_id(account_id)
    saved_subdomain = insint.user.subdomain
    Apartment::Tenant.switch(saved_subdomain) do
      if MessageSetup.check_ability
        InsintRestockJob.perform_later(saved_subdomain, params.permit!)
        render json: {success: true, message: 'Информация сохранена в cases restock'}
      else
        render json: {error: true, message: 'не смогли добавить запись в cases restock Сервис не включен'}
      end
    end
  end

  def preorder
    account_id = params['insales_account_id']
    puts "account_id => #{account_id}"

    insint = Insint.find_by_insales_account_id(account_id)
    saved_subdomain = insint.user.subdomain
    Apartment::Tenant.switch(saved_subdomain) do
      if MessageSetup.check_ability
        InsintPreorderJob.perform_later(saved_subdomain, params.permit!)
        render json: {success: true, message: 'Информация сохранена в cases preorder'}
      else
        render json: {error: false, message: 'не смогли добавить запись в cases preorder Сервис не включен'}
      end
    end
  end

  def extra_data
    data = {
      discount: 111,
      discount_type: 'MONEY',
      title: 'Ваша пошлина за заказ'
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
