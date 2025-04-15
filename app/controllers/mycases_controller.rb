class MycasesController < ApplicationController
  before_action :authenticate_user!
  before_action :set_mycase, only: [:show, :edit, :update, :destroy]
  include SearchQueryRansack
  include DownloadExcel
  include BulkDelete

  def index
    @search = Mycase.all.ransack(params[:q])
    @search.sorts = 'id desc' if @search.sorts.empty?
    @mycases = @search.result.includes(:client).paginate(page: params[:page], per_page: 50)
  end

  def show
    render :edit
  end

  def new
    if params[:client_id].present?
      client = Client.find_by_id(params[:client_id])
      @mycase = Mycase.new(
        client_id: client.id,
        client: client,
        casetype: params[:casetype]
      )
      items = client.favorites
      items.each do |fav|
        product = Product.find(fav.product_id)
        variant = product.variants.first
        @mycase.lines.build(
          product_id: product.id,
          variant_id: variant.id,
          quantity: 1,
          price: variant.price
        )
      end
    else
      @mycase = Mycase.new
      @mycase.lines.build
    end
  end

  def edit
    @lines = @mycase.lines
  end

  def create
    @mycase = Mycase.new(mycase_params)

    respond_to do |format|
      if @mycase.save
        flash.now[:success] = t('.success')
        format.turbo_stream do
          render turbo_stream: [
            render_turbo_flash
          ]
        end
        format.html { redirect_to mycases_url, notice: t('.success')}
        format.json { render :show, status: :created, location: @mycase }
      else
        format.html { render :new, status: :unprocessable_entity }
        format.json { render json: @mycase.errors, status: :unprocessable_entity }
      end
    end
  end

  def update
    respond_to do |format|
      if @mycase.update(mycase_params)
        format.html { redirect_to mycases_url, notice: t('.success') }
        format.json { render :show, status: :ok, location: @mycase }
      else
        format.html { render :edit, status: :unprocessable_entity }
        format.json { render json: @mycase.errors, status: :unprocessable_entity }
      end
    end
  end

  def destroy
    @mycase.destroy
    respond_to do |format|
      flash.now[:success] = t('.success')
      format.turbo_stream do
        render turbo_stream: [
          render_turbo_flash
        ]
      end
      format.html { redirect_to mycases_url, notice: t('.success') }
      format.json { head :no_content }
    end
  end

  private

  def set_mycase
    @mycase = Mycase.find(params[:id])
  end

  def mycase_params
    params.require(:mycase).permit(
      :number,
      :client_id,
      :casetype,
      :insales_financial_status,
      :insales_custom_status_title,
      :insales_order_id,
      :status,
      lines_attributes: [
        :id,
        :product_id,
        :variant_id,
        :quantity,
        :price,
        :_destroy
      ]
    )
  end
end
