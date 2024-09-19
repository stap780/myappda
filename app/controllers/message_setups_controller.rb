class MessageSetupsController < ApplicationController
  before_action :authenticate_user!
  before_action :set_message_setup, only: %i[show edit update destroy]
  include ActionView::RecordIdentifier

  # GET /message_setups
  def index
    @search = MessageSetup.all.ransack(params[:q])
    @search.sorts = 'id asc' if @search.sorts.empty?
    @message_setups = @search.result.paginate(page: params[:page], per_page: 30)
    redirect_to dashboard_services_url
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
        flash.now[:success] = t(".success")
        format.turbo_stream do
          render turbo_stream: [
            turbo_stream.update( "message_setup_buttons_user_#{current_user.id}", ''),
            render_turbo_flash
          ]
        end
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
        flash.now[:success] = t(".success")
        format.turbo_stream do
          render turbo_stream: [
            turbo_stream.replace( dom_id(current_user, dom_id(@message_setup)), partial: 'message_setups/message_setup', 
                                                                                locals: { message_setup: @message_setup, current_user: current_user }),
            render_turbo_flash
          ]
        end
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
      format.turbo_stream {flash.now[:success] = t(".success")}
      format.html { redirect_to dashboard_services_url, notice: "Message setup was successfully destroyed." }
      format.json { head :no_content }
    end
  end

# POST /message_setups
  def delete_selected
    @message_setups = MessageSetup.find(params[:ids])
    @message_setups.each do |message_setup|
        message_setup.destroy
    end
    respond_to do |format|
      format.html { redirect_to dashboard_services_url, notice: "Message setup was successfully destroyed." }
      format.json { render json: { :status => "ok", :message => "destroyed" } }
    end
  end

  def api_create_restock_xml
    if !MessageSetup.first.present?
      if current_user.insints.present? && current_user.insints.last.status
        ms = MessageSetup.create
        ms.api_create_restock_xml
        respond_to do |format|
          flash.now[:success] = t(".success")
          format.turbo_stream do
            render turbo_stream: [
              render_turbo_flash
            ]
          end
        end
      else
        respond_to do |format|
          flash.now[:error] = 'Настройте интеграцию с insales'
          format.turbo_stream do
            render turbo_stream: [
              render_turbo_flash
            ]
          end
        end
      end
    else
      respond_to do |format|
        flash.now[:error] = 'ссылка на файл уже прописана'
        format.turbo_stream do
          render turbo_stream: [
            render_turbo_flash
          ]
        end
      end
    end
  end

  private
    def set_message_setup
      @message_setup = MessageSetup.find(params[:id])
    end

    def message_setup_params
      params.require(:message_setup).permit(:title, :handle, :description, :status, :payplan_id, :valid_until, :product_xml)
    end
end
