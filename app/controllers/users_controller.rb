class UsersController < ApplicationController
  before_action :authenticate_user!
  before_action :set_user, only: [:show, :edit, :update, :destroy, :check_email, :add_message_setup_ability, :add_insales_order_webhook]
  before_action :authenticate_admin!, only: [:index], except: [:stop_impersonating]


  def index
    @search = User.ransack(params[:q])
    @search.sorts = 'id asc' if @search.sorts.empty?
    @users = @search.result.paginate(page: params[:page], per_page: 30)
    @favorite_setup = FavoriteSetup.first
    @restock_setup = RestockSetup.first
    @message_setup = MessageSetup.first
  end

  def new
    redirect_to dashboard_path, alert: 'Access denied.' unless @user == current_user || current_admin
  end

  def edit
    redirect_to dashboard_path, alert: 'Access denied.' unless @user == current_user || current_admin
  end

  def show
    redirect_to dashboard_path, alert: 'Access denied.' unless @user == current_user || current_admin
  end

  def update
    @user.image.attach(params[:user][:image]) if params[:user][:image]
    respond_to do |format|
      if @user.update(user_params)
        redirect_path = @user == current_user ? dashboard_path : users_url
        format.html { redirect_to redirect_path, notice: "User was successfully updated."}
        format.json { render :show, status: :ok, location: @user }
      else
        format.html { render :edit, status: :unprocessable_entity }
        format.json { render json: @user.errors, status: :unprocessable_entity }
      end
    end
  end

  def destroy
    if User.count > 1 && !@user.admin?
      @user.destroy
      respond_to do |format|
        format.html { redirect_back fallback_location: users_url, notice: 'Пользователь удалён' }
        format.json { head :no_content }
      end
    else
      redirect_to users_url, notice: 'Нельзя удалить последнего пользователя или админа'
    end
  end

  def delete_image
    ActiveStorage::Attachment.where(id: params[:image_id])[0].purge
    respond_to do |format|
      #format.html { redirect_to edit_product_path(params[:id]), notice: 'Image was successfully deleted.' }
      format.json { render json: { :status => "ok", :message => "destroyed" } }
      format.js do
        flash.now[:notice] = 'Image was successfully deleted.'
      end
    end
  end

  def check_email
    notice = @user.check_email.present? ? 'Почта настроена верно и тестовое сообщение отправили' : 'Не работает Почта!'
    respond_to do |format|
      # format.js do
      #   flash.now[:notice] = notice
      # end
      flash.now[:success] = notice
      format.turbo_stream do
        render turbo_stream: [
          render_turbo_flash
        ]
      end
    end
  end

  def add_message_setup_ability
    notice = @user.add_message_setup_ability
    respond_to do |format|
      flash.now[:success] = notice
      format.turbo_stream do
        render turbo_stream: [
          render_turbo_flash
        ]
      end
    end
  end

  def add_insales_order_webhook
    service = ApiInsales.new(@user.insints.first)
    message = service.add_order_webhook
    # service.delete_order_webhook if @user.status == false
    respond_to do |format|
      flash.now[:success] = message
      format.turbo_stream do
        render turbo_stream: [
          render_turbo_flash
        ]
      end
    end
  end

  def impersonate
    user = User.find(params[:id])
    impersonate_user(user)
    redirect_to after_sign_in_path_for(user), allow_other_host: true
  end

  def stop_impersonating
    stop_impersonating_user
    redirect_to after_sign_in_path_for(User.where(role: 'admin').first), allow_other_host: true
  end

  private

  def set_user
    @user = User.find(params[:id])
  end
  def user_params
    params.require(:user).permit(:name, :email, :subdomain, :phone, :admin, :avatar, avatar_attachment_attributes: [:id, :_destroy])
  end

end
