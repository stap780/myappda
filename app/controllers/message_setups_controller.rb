class MessageSetupsController < ApplicationController
  before_action :authenticate_user!
  before_action :set_message_setup, only: [:show, :edit, :update, :destroy]

  # GET /message_setups
  def index
    @search = MessageSetup.all.ransack(params[:q])
    @search.sorts = 'id asc' if @search.sorts.empty?
    @message_setups = @search.result.paginate(page: params[:page], per_page: 30)
  end

  # GET /message_setups/1
  def show
  end

  # GET /message_setups/new
  def new
    if current_user.insints.present? && current_user.insints.last.status
      @message_setup = MessageSetup.new
    else
      redirect_to dashboard_services_url, notice: "Настройте интеграцию с insales"
    end
  end

  # GET /message_setups/1/edit
  def edit
  end

  # POST /message_setups
  def create
    @message_setup = MessageSetup.new(message_setup_params)

    respond_to do |format|
      if @message_setup.save
        format.html { redirect_to dashboard_services_url, notice: "Message setup was successfully created." }
        format.json { render :show, status: :created, location: @message_setup }
      else
        format.html { render :new, status: :unprocessable_entity }
        format.json { render json: @message_setup.errors, status: :unprocessable_entity }
      end
    end

  end

  # PATCH/PUT /message_setups/1
  def update
    respond_to do |format|
      if @message_setup.update(message_setup_params)
        format.html { redirect_to dashboard_services_url, notice: "Настройки обновились." }
        format.json { render :show, status: :ok, location: @message_setup }
      else
        format.html { render :edit, status: :unprocessable_entity }
        format.json { render json: @message_setup.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /message_setups/1
  def destroy
    @message_setup.destroy
    respond_to do |format|
      format.html { redirect_to dashboard_services_url, notice: "Message setup was successfully destroyed." }
      format.json { head :no_content }
    end
  end

# POST /message_setups
  def delete_selected
    @message_setups = Message Setup.find(params[:ids])
    @message_setups.each do |message_setup|
        message_setup.destroy
    end
    respond_to do |format|
      format.html { redirect_to dashboard_services_url, notice: "Message setup was successfully destroyed." }
      format.json { render json: { :status => "ok", :message => "destroyed" } }
    end
  end


  private
    # Use callbacks to share common setup or constraints between actions.
    def set_message_setup
      @message_setup = MessageSetup.find(params[:id])
    end

    # Only allow a trusted parameter "white list" through.
    def message_setup_params
      params.require(:message_setup).permit(:title, :handle, :description, :status, :payplan_id, :valid_until, :restock_xml)
    end
end
