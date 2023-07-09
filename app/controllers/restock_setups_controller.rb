class RestockSetupsController < ApplicationController
  
  #####

  ### Этот раздел не работает, так как сменили принцип всего приложения
  ### Теперь у нас Триггеры и всё настраивается в разделе Message

  #####
  
  
  before_action :authenticate_user!
  before_action :set_restock_setup, only: [:show, :edit, :update, :destroy]

  # GET /restock_setups
  def index
    #@restock_setups = RestockSetup.all
    @search = RestockSetup.ransack(params[:q])
    @search.sorts = 'id asc' if @search.sorts.empty?
    @restock_setups = @search.result.paginate(page: params[:page], per_page: 30)
  end

  # GET /restock_setups/1
  def show
  end

  # GET /restock_setups/new
  def new
    if current_user.insints.present? && current_user.insints.last.status
      @restock_setup = RestockSetup.new
    else
      redirect_to dashboard_services_url, notice: "Настройте интеграцию с insales"
    end
  end

  # GET /restock_setups/1/edit
  def edit
  end

  # POST /restock_setups
  def create
    @restock_setup = RestockSetup.new(restock_setup_params)

    respond_to do |format|
      if @restock_setup.save
        format.html { redirect_to dashboard_services_url, notice: "Restock setup was successfully created." }
        format.json { render :show, status: :created, location: @restock_setup }
      else
        format.html { render :new, status: :unprocessable_entity }
        format.json { render json: @restock_setup.errors, status: :unprocessable_entity }
      end
    end

  end

  # PATCH/PUT /restock_setups/1
  def update
  respond_to do |format|
    if @restock_setup.update(restock_setup_params)
      format.html { redirect_to dashboard_services_url, notice: "Restock setup was successfully updated." }
      format.json { render :show, status: :ok, location: @restock_setup }
    else
      format.html { render :edit, status: :unprocessable_entity }
      format.json { render json: @restock_setup.errors, status: :unprocessable_entity }
    end
  end
  end

  # DELETE /restock_setups/1
  def destroy
  @restock_setup.destroy
  respond_to do |format|
    format.html { redirect_to dashboard_services_url, notice: "Restock setup was successfully destroyed." }
    format.json { head :no_content }
  end
  end

# POST /restock_setups
  def delete_selected
    @restock_setups = RestockSetup.find(params[:ids])
    @restock_setups.each do |restock_setup|
        restock_setup.destroy
    end
    respond_to do |format|
      format.html { redirect_to restock_setups_url, notice: "Restock setup was successfully destroyed." }
      format.json { render json: { :status => "ok", :message => "destroyed" } }
    end
  end


  private
    # Use callbacks to share common setup or constraints between actions.
    def set_restock_setup
      @restock_setup = RestockSetup.find(params[:id])
    end

    # Only allow a trusted parameter "white list" through.
    def restock_setup_params
      params.require(:restock_setup).permit(:title, :handle, :description, :status, :payplan_id, :valid_until)
    end
end
