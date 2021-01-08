class PayplansController < ApplicationController
  before_action :authenticate_user!
  # before_action :authenticate_admin!
  before_action :set_payplan, only: [:show, :edit, :update, :destroy]

  # GET /payplans
  # GET /payplans.json
  def index
    @payplans = Payplan.all
  end

  # GET /payplans/1
  # GET /payplans/1.json
  def show
  end

  # GET /payplans/new
  def new
    @payplan = Payplan.new
  end

  # GET /payplans/1/edit
  def edit
  end

  # POST /payplans
  # POST /payplans.json
  def create
    @payplan = Payplan.new(payplan_params)

    respond_to do |format|
      if @payplan.save
        format.html { redirect_to @payplan, notice: 'Payplan was successfully created.' }
        format.json { render :show, status: :created, location: @payplan }
      else
        format.html { render :new }
        format.json { render json: @payplan.errors, status: :unprocessable_entity }
      end
    end
  end

  # PATCH/PUT /payplans/1
  # PATCH/PUT /payplans/1.json
  def update
    respond_to do |format|
      if @payplan.update(payplan_params)
        format.html { redirect_to @payplan, notice: 'Payplan was successfully updated.' }
        format.json { render :show, status: :ok, location: @payplan }
      else
        format.html { render :edit }
        format.json { render json: @payplan.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /payplans/1
  # DELETE /payplans/1.json
  def destroy
    @payplan.destroy
    respond_to do |format|
      format.html { redirect_to payplans_url, notice: 'Payplan was successfully destroyed.' }
      format.json { head :no_content }
    end
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_payplan
      @payplan = Payplan.find(params[:id])
    end

    # Never trust parameters from the scary internet, only allow the white list through.
    def payplan_params
      params.require(:payplan).permit(:period, :price)
    end
end
