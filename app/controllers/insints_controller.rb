class InsintsController < ApplicationController
  before_action :set_insint, only: [:show, :edit, :update, :destroy]

  # GET /insints
  # GET /insints.json
  def index
    @insints = Insint.all
  end

  # GET /insints/1
  # GET /insints/1.json
  def show
  end

  # GET /insints/new
  def new
    @insint = Insint.new
  end

  # GET /insints/1/edit
  def edit
  end

  # POST /insints
  # POST /insints.json
  def create
    @insint = Insint.new(insint_params)

    respond_to do |format|
      if @insint.save
        format.html { redirect_to @insint, notice: 'Insint was successfully created.' }
        format.json { render :show, status: :created, location: @insint }
      else
        format.html { render :new }
        format.json { render json: @insint.errors, status: :unprocessable_entity }
      end
    end
  end

  # PATCH/PUT /insints/1
  # PATCH/PUT /insints/1.json
  def update
    respond_to do |format|
      if @insint.update(insint_params)
        format.html { redirect_to @insint, notice: 'Insint was successfully updated.' }
        format.json { render :show, status: :ok, location: @insint }
      else
        format.html { render :edit }
        format.json { render json: @insint.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /insints/1
  # DELETE /insints/1.json
  def destroy
    @insint.destroy
    respond_to do |format|
      format.html { redirect_to insints_url, notice: 'Insint was successfully destroyed.' }
      format.json { head :no_content }
    end
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_insint
      @insint = Insint.find(params[:id])
    end

    # Never trust parameters from the scary internet, only allow the white list through.
    def insint_params
      params.require(:insint).permit(:subdomen, :password, :insalesid, :user_id)
    end
end
