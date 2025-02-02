class InvoicesController < ApplicationController
  before_action :authenticate_user!
  before_action :set_invoice, only: [:show, :edit, :update, :destroy]

  def index
    @search = Invoice.ransack(params[:q])
    @search.sorts = 'id desc' if @search.sorts.empty?
    @invoices = @search.result.paginate(page: params[:page], per_page: 100)
  end

  def show
  end

  def new
    @invoice = Invoice.new
  end

  def edit
    redirect_to invoices_url, notice: "Invoice can't be edit."
  end

  def create
    @invoice = Invoice.new(invoice_params)
    respond_to do |format|
      if @invoice.save
        format.html { redirect_to @invoice, notice: 'Счет создан' }
        format.json { render :show, status: :created, location: @invoice }
      else
        format.html { render :new }
        format.json { render json: @invoice.errors, status: :unprocessable_entity }
      end
    end
  end

  def update
    respond_to do |format|
      if @invoice.update(invoice_params)
        format.html { redirect_to @invoice, notice: 'Счет обновлен.' }
        format.json { render :show, status: :ok, location: @invoice }
      else
        format.html { render :edit }
        format.json { render json: @invoice.errors, status: :unprocessable_entity }
      end
    end
  end

  def destroy
    @invoice.destroy
    respond_to do |format|
      format.html { redirect_to invoices_url, notice: 'Invoice was successfully destroyed.' }
      format.json { head :no_content }
    end
  end

  def print
		@company = Company.first
    @invoice = Invoice.find(params[:invoice_id])
		respond_to do |format|
			format.html
		    format.pdf do
		      render :pdf => "Счёт #{@invoice.id}",
		             :template => "invoices/pdfsight",
                 :show_as_html => params.key?('debug')
		    end
		end
	end

  private
    def set_invoice
      @invoice = Invoice.find(params[:id])
    end

    def invoice_params
      params.require(:invoice).permit(:payplan_id, :sum, :status, :payertype, :paymenttype, :service_handle)
    end
end
