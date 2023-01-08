class OrderStatusChangesController < ApplicationController
  before_action :authenticate_user!
  before_action :set_order_status_change, only: [:show, :edit, :update, :destroy]

  # GET /order_status_changes
  def index
    #@order_status_changes = OrderStatusChange.all
    @search = OrderStatusChange.all.ransack(params[:q])
    @search.sorts = 'id desc' if @search.sorts.empty?
    @order_status_changes = @search.result.paginate(page: params[:page], per_page: 30)
  end

  # GET /order_status_changes/1
  def show
  end

  # GET /order_status_changes/new
  def new
    @order_status_change = OrderStatusChange.new
  end

  # GET /order_status_changes/1/edit
  def edit
  end

  # POST /order_status_changes
  def create
    @order_status_change = OrderStatusChange.new(order_status_change_params)

    respond_to do |format|
      if @order_status_change.save
        format.html { redirect_to @order_status_change, notice: "Order status change was successfully created." }
        format.json { render :show, status: :created, location: @order_status_change }
      else
        format.html { render :new, status: :unprocessable_entity }
        format.json { render json: @order_status_change.errors, status: :unprocessable_entity }
      end
    end

  end

  # PATCH/PUT /order_status_changes/1
  def update
    respond_to do |format|
      if @order_status_change.update(order_status_change_params)
        format.html { redirect_to @order_status_change, notice: "Order status change was successfully updated." }
        format.json { render :show, status: :ok, location: @order_status_change }
      else
        format.html { render :edit, status: :unprocessable_entity }
        format.json { render json: @order_status_change.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /order_status_changes/1
  def destroy
    @order_status_change.destroy
    respond_to do |format|
      format.html { redirect_to order_status_changes_url, notice: "Order status change was successfully destroyed." }
      format.json { head :no_content }
    end
  end

# POST /order_status_changes
  def delete_selected
    @order_status_changes = Order Status Change.find(params[:ids])
    @order_status_changes.each do |order_status_change|
        order_status_change.destroy
    end
    respond_to do |format|
      format.html { redirect_to order_status_changes_url, notice: "Order status change was successfully destroyed." }
      format.json { render json: { :status => "ok", :message => "destroyed" } }
    end
  end


  private
    # Use callbacks to share common setup or constraints between actions.
    def set_order_status_change
      @order_status_change = OrderStatusChange.find(params[:id])
    end

    # Only allow a trusted parameter "white list" through.
    def order_status_change_params
      params.require(:order_status_change).permit(:client_id, :event_id, :insales_order_id, :insales_order_number, :insales_custom_status_title, :insales_financial_status)
    end
end
