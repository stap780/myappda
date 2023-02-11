class UsersController < ApplicationController
  before_action :authenticate_user!
  before_action :set_user, only: [:show, :edit, :update, :destroy]
  before_action :authenticate_admin!, only: [:index]


  def index
    @search = User.ransack(params[:q])
    @search.sorts = 'id asc' if @search.sorts.empty?
    @users = @search.result.paginate(page: params[:page], per_page: 30)
    @favorite_setup = FavoriteSetup.first
    @restock_setup = RestockSetup.first
    @message_setup = MessageSetup.first
  end

  def edit
    @user = User.find(params[:id])
    redirect_to dashboard_path, alert: 'Access denied.' unless @user == current_user || current_admin
  end

  def show
    @user = User.find(params[:id])
    redirect_to dashboard_path, alert: 'Access denied.' unless @user == current_user || current_admin
  end

  # PATCH/PUT /users/1 or /users/1.json
  def update
    @user.avatar.attach(params[:user][:avatar]) if params[:user][:avatar]
    respond_to do |format|
      #if @user.update(name: params[:user][:name], email: params[:user][:email], role_id: params[:user][:role_id])
      if @user.update(user_params)
        redirect_path = @user == current_user ? dashboard_path : users_url
        format.html { redirect_to redirect_path, notice: "User was successfully updated." }
        format.json { render :show, status: :ok, location: @user }
      else
        format.html { render :edit, status: :unprocessable_entity }
        format.json { render json: @user.errors, status: :unprocessable_entity }
      end
    end
  end


  def destroy
    @user = User.find(params[:id])
    if (User.count > 1) && !@user.admin?
      @user.destroy! if (User.count > 1) && !current_admin

      respond_to do |format|
        format.html { redirect_to users_url, notice: 'Пользователь удалён' }
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
    end
  end

  private

  def set_user
    @user = User.find(params[:id])
  end
    # Only allow a trusted parameter "white list" through.
    def user_params
      params.require(:user).permit(:name, :email, :subdomain, :avatar, :phone, :admin)
    end

end
