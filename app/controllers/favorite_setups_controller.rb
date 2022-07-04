class FavoriteSetupsController < ApplicationController
  before_action :authenticate_user!
  before_action :set_favorite_setup, only: [:show, :edit, :update, :destroy, :status_change]

  # GET /favorite_setups
  def index
    @search = FavoriteSetup.ransack(params[:q])
    @search.sorts = 'id asc' if @search.sorts.empty?
    @favorite_setups = @search.result.paginate(page: params[:page], per_page: 30)
  end

  # GET /favorite_setups/1
  def show
  end

  # GET /favorite_setups/new
  def new
    if current_user.insints.present? && current_user.insints.last.status
      @favorite_setup = FavoriteSetup.new
    else
      redirect_to dashboard_services_url, notice: "Настройте интеграцию с insales"
    end
  end

  # GET /favorite_setups/1/edit
  def edit
  end

  # POST /favorite_setups
  def create
    @favorite_setup = FavoriteSetup.new(favorite_setup_params)
    respond_to do |format|
      if @favorite_setup.save
        # @item.apartment_add_new_item_to_user if current_admin # - это старая реализация которая сейчас не работает
        format.html { redirect_to dashboard_services_url, notice: "настройки сохранены" }
        format.json { render :show, status: :created, location: @favorite_setup }
      else
        format.html { render :new, status: :unprocessable_entity }
        format.json { render json: @favorite_setup.errors, status: :unprocessable_entity }
      end
    end
  end

  # PATCH/PUT /favorite_setups/1
  def update
    respond_to do |format|
      if @favorite_setup.update(favorite_setup_params)
        format.html { redirect_to dashboard_services_url, notice: "Настройки обновлены" }
        format.json { render :show, status: :ok, location: @favorite_setup }
      else
        format.html { render :edit, status: :unprocessable_entity }
        format.json { render json: @favorite_setup.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /favorite_setups/1
  def destroy
    # @item.apartment_delete_item_from_user if current_admin
    @favorite_setup.destroy
    respond_to do |format|
      format.html { redirect_to dashboard_services_url, notice: "FavoriteSetup was successfully destroyed." }
      format.json { head :no_content }
    end
  end


  private
    # Use callbacks to share common setup or constraints between actions.
    def set_favorite_setup
      @favorite_setup = FavoriteSetup.find(params[:id])
    end

    # Only allow a trusted parameter "white list" through.
    def favorite_setup_params
      params.require(:favorite_setup).permit(:title, :handle, :description, :status, :payplan_id, :valid_until)
    end
end
