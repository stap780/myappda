# DiscountsController < ApplicationController
class DiscountsController < ApplicationController
  before_action :authenticate_user!
  before_action :set_discount, only: [:show, :edit, :update, :destroy, :sort]

  def index
    @search = Discount.ransack(params[:q])
    @search.sorts = 'position asc' if @search.sorts.empty?
    @discounts = @search.result(distinct: true).paginate(page: params[:page], per_page: 100)
  end

  def show; end

  def new
    @discount = Discount.new
  end

  def edit; end

  def create
    @discount = Discount.new(discount_params)

    respond_to do |format|
      if @discount.save
        format.html { redirect_to @discount, notice: 'Discount was successfully created.' }
        format.json { render :show, status: :created, location: @discount }
      else
        format.html { render :new, status: :unprocessable_entity }
        format.json { render json: @discount.errors, status: :unprocessable_entity }
      end
    end
  end

  def update
    respond_to do |format|
      if @discount.update(discount_params)
        format.html { redirect_to @discount, notice: 'Discount was successfully updated.' }
        format.json { render :show, status: :ok, location: @discount }
      else
        format.html { render :edit, status: :unprocessable_entity }
        format.json { render json: @discount.errors, status: :unprocessable_entity }
      end
    end
  end

  def destroy
    @discount.destroy!

    respond_to do |format|
      flash.now[:success] = t('.success')
      format.turbo_stream do
        render turbo_stream: [
          render_turbo_flash
        ]
      end
      format.html { redirect_to discounts_path, status: :see_other, notice: t('.success') }
      format.json { head :no_content }
    end

  end

  def sort
    @discount.insert_at params[:new_position]
    head :ok
  end

  private

  def set_discount
    @discount = Discount.find(params[:id])
  end

  def discount_params
    params.require(:discount).permit(:title, :rule, :move, :position, :shift, :points, :notice)
  end

end
