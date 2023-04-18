class CasesController < ApplicationController
  before_action :authenticate_user!
  before_action :set_case, only: [:show, :edit, :update, :destroy]

  # GET /cases
  def index
    #@cases = Case.all
    @search = Case.all.ransack(params[:q])
    @search.sorts = 'id desc' if @search.sorts.empty?
    @cases = @search.result.includes(:client).paginate(page: params[:page], per_page: 30)
  end

  # GET /cases/1
  def show
    render :edit
  end

  # GET /cases/new
  def new
    @case = Case.new
  end

  # GET /cases/1/edit
  def edit
    @lines = @case.lines
  end

  # POST /cases
  def create
    @case = Case.new(case_params)

    respond_to do |format|
      if @case.save
        format.html { redirect_to cases_url, notice: "Case was successfully created." }
        format.json { render :show, status: :created, location: @case }
      else
        format.html { render :new, status: :unprocessable_entity }
        format.json { render json: @case.errors, status: :unprocessable_entity }
      end
    end

  end

  # PATCH/PUT /cases/1
  def update
    respond_to do |format|
        if @case.update(case_params)
        format.html { redirect_to cases_url, notice: "Case was successfully updated." }
        format.json { render :show, status: :ok, location: @case }
        else
        format.html { render :edit, status: :unprocessable_entity }
        format.json { render json: @case.errors, status: :unprocessable_entity }
        end
    end
  end

  # DELETE /cases/1
  def destroy
    @case.destroy
    respond_to do |format|
        format.html { redirect_to cases_url, notice: "Case was successfully destroyed." }
        format.json { head :no_content }
    end
  end

# POST /cases
#   def delete_selected
#     @cases = Case.find(params[:ids])
#     @cases.each do |case|
#         case.destroy
#     end
#     respond_to do |format|
#       format.html { redirect_to cases_url, notice: "Case was successfully destroyed." }
#       format.json { render json: { :status => "ok", :message => "destroyed" } }
#     end
#   end


  private
    # Use callbacks to share common setup or constraints between actions.
    def set_case
      @case = Case.find(params[:id])
    end

    # Only allow a trusted parameter "white list" through.
    def case_params
        params.require(:case).permit(:number, :client_id, :casetype,:insales_financial_status, :insales_custom_status_title, :insales_order_id, :status)
    end
end
