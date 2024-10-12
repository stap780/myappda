class VariantsController < ApplicationController
  before_action :authenticate_user!
  before_action :set_variant, only: [:show, :edit, :update, :destroy]

  # GET /variants
  def index
    #@variants = Variant.all
    @search = Variant.ransack(params[:q])
    @search.sorts = 'id asc' if @search.sorts.empty?
    @variants = @search.result.paginate(page: params[:page], per_page: 30)
  end

  # GET /variants/1
  def show
  end

  # GET /variants/new
  def new
    @variant = Variant.new
  end

  # GET /variants/1/edit
  def edit
  end

  # POST /variants
  def create
    @variant = Variant.new(variant_params)

    respond_to do |format|
      if @variant.save
        format.html { redirect_to @variant, notice: "Variant was successfully created." }
        format.json { render :show, status: :created, location: @variant }
      else
        format.html { render :new, status: :unprocessable_entity }
        format.json { render json: @variant.errors, status: :unprocessable_entity }
      end
    end

  end

  # PATCH/PUT /variants/1
  def update
  respond_to do |format|
    if @variant.update(variant_params)
      format.html { redirect_to @variant, notice: "Variant was successfully updated." }
      format.json { render :show, status: :ok, location: @variant }
    else
      format.html { render :edit, status: :unprocessable_entity }
      format.json { render json: @variant.errors, status: :unprocessable_entity }
    end
  end
  end

  # DELETE /variants/1
  def destroy
  @variant.destroy
  respond_to do |format|
    format.html { redirect_to variants_url, notice: "Variant was successfully destroyed." }
    format.json { head :no_content }
  end
  end

# POST /variants
  def delete_selected
    @variants = Variant.find(params[:ids])
    @variants.each do |variant|
        variant.destroy
    end
    respond_to do |format|
      format.html { redirect_to variants_url, notice: "Variant was successfully destroyed." }
      format.json { render json: { status: "ok", message: "destroyed" } }
    end
  end


  private
    # Use callbacks to share common setup or constraints between actions.
    def set_variant
      @variant = Variant.find(params[:id])
    end

    # Only allow a trusted parameter "white list" through.
    def variant_params
      params.require(:variant).permit(:insid, :sku, :quantity, :price, :product_id)
    end
end
