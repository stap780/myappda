# ProductsController < ApplicationController
class ProductsController < ApplicationController
  before_action :authenticate_user!
  before_action :set_product, only: [:show, :edit, :update, :destroy, :insales_info]
  include SearchQueryRansack
  include DownloadExcel
  include BulkDelete
  include ActionView::RecordIdentifier

  def index
    @search = Product.includes(:variants, :favorites, :preorders, :abandoned_carts, :restocks).ransack(params[:q])
    @search.sorts = 'id desc' if @search.sorts.empty?
    @products = @search.result(distinct: true).paginate(page: params[:page], per_page: 50)
  end

  def show; end

  def new
    redirect_to products_url, notice: 'товары создаются в InSales'
  end

  def edit
    redirect_to products_url, notice: 'Товары создаются в InSales'
  end

  def create
    @product = Product.new(product_params)

    respond_to do |format|
      if @product.save
        format.html { redirect_to @product, notice: 'Product was successfully created.' }
        format.json { render :show, status: :created, location: @product }
      else
        format.html { render :new, status: :unprocessable_entity }
        format.json { render json: @product.errors, status: :unprocessable_entity }
      end
    end

  end

  def update
    respond_to do |format|
      if @product.update(product_params)
        format.html { redirect_to @product, notice: 'Product was successfully updated.' }
        format.json { render :show, status: :ok, location: @product }
      else
        format.html { render :edit, status: :unprocessable_entity }
        format.json { render json: @product.errors, status: :unprocessable_entity }
      end
    end
  end

  def insales_info
    @product.get_ins_data
    @product.create_variant_webhook
  end

  def destroy
    @product.destroy
    respond_to do |format|
      format.html { redirect_to products_url, notice: 'Product was successfully destroyed.' }
      format.json { head :no_content }
    end
  end

  private

  def set_product
    @product = Product.find(params[:id])
  end

  def product_params
    params.require(:product).permit(:insid, :title, :price, :image_link, variants_attributes: [:id, :insid, :product_id, :sku, :quantity, :price, :_destroy])
  end

end
