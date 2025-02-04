class MycasesController < ApplicationController
  before_action :authenticate_user!
  before_action :set_mycase, only: [:show, :edit, :update, :destroy]
  include SearchQueryRansack
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
    @mycase = Mycase.new
  end

  def edit
    @lines = @mycase.lines
  end

  def create
    @mycase = Mycase.new(mycase_params)

    respond_to do |format|
      if @mycase.save
        format.html { redirect_to mycases_url, notice: 'Mycase was successfully created.' }
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
        format.html { redirect_to mycases_url, notice: 'Mycase was successfully updated.' }
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
      format.html { redirect_to mycases_url, notice: 'Mycase was successfully destroyed.' }
      format.json { head :no_content }
    end
  end

  def csv_export
    # if params[:product_ids]
    #   ProductEtiketkiJob.perform_later(params[:product_ids], current_user.id)
    #   render turbo_stream:
    #     turbo_stream.update(
    #       "modal",
    #       template: "shared/pending_bulk"
    #     )
    # else
    #   notice = 'Выберите товары'
    #   redirect_to mycases_url, alert: notice
    # end
  end

  private
    def set_mycase
      @mycase = Mycase.find(params[:id])
    end

    def mycase_params
        params.require(:mycase).permit(:number, :client_id, :mycasetype,:insales_financial_status, :insales_custom_status_title, :insales_order_id, :status)
    end
end
