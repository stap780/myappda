class MycasesController < ApplicationController
  before_action :authenticate_user!
  before_action :set_mycase, only: [:show, :edit, :update, :destroy]

  # GET /mycases
  def index
    #@mycases = Mycase.all
    @search = Mycase.all.ransack(params[:q])
    @search.sorts = 'id desc' if @search.sorts.empty?
    @mycases = @search.result.includes(:client).paginate(page: params[:page], per_page: 30)
  end

  # GET /mycases/1
  def show
    render :edit
  end

  # GET /mycases/new
  def new
    @mycase = Mycase.new
  end

  # GET /mycases/1/edit
  def edit
    @lines = @mycase.lines
  end

  # POST /mycases
  def create
    @mycase = Mycase.new(mycase_params)

    respond_to do |format|
      if @mycase.save
        format.html { redirect_to mycases_url, notice: "Mycase was successfully created." }
        format.json { render :show, status: :created, location: @mycase }
      else
        format.html { render :new, status: :unprocessable_entity }
        format.json { render json: @mycase.errors, status: :unprocessable_entity }
      end
    end

  end

  # PATCH/PUT /mycases/1
  def update
    respond_to do |format|
        if @mycase.update(mycase_params)
        format.html { redirect_to mycases_url, notice: "Mycase was successfully updated." }
        format.json { render :show, status: :ok, location: @mycase }
        else
        format.html { render :edit, status: :unprocessable_entity }
        format.json { render json: @mycase.errors, status: :unprocessable_entity }
        end
    end
  end

  # DELETE /mycases/1
  def destroy
    @mycase.destroy
    respond_to do |format|
        format.html { redirect_to mycases_url, notice: "Mycase was successfully destroyed." }
        format.json { head :no_content }
    end
  end

# POST /mycases
#   def delete_selected
#     @mycases = Mycase.find(params[:ids])
#     @mycases.each do |mycase|
#         mycase.destroy
#     end
#     respond_to do |format|
#       format.html { redirect_to mycases_url, notice: "Mycase was successfully destroyed." }
#       format.json { render json: { :status => "ok", :message => "destroyed" } }
#     end
#   end


  private
    # Use callbacks to share common setup or constraints between actions.
    def set_mycase
      @mycase = Mycase.find(params[:id])
    end

    # Only allow a trusted parameter "white list" through.
    def mycase_params
        params.require(:mycase).permit(:number, :client_id, :mycasetype,:insales_financial_status, :insales_custom_status_title, :insales_order_id, :status)
    end
end
