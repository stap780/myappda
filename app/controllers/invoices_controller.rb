class InvoicesController < ApplicationController
  before_action :authenticate_user!
  before_action :authenticate_admin!, only: [:index]
  before_action :set_invoice, only: [:show, :edit, :update, :destroy]

  # GET /invoices
  # GET /invoices.json
  def index
    @invoices = Invoice.all
  end

  # GET /invoices/1
  # GET /invoices/1.json
  def show
  end

  # GET /invoices/new
  def new
    @invoice = Invoice.new
  end

  # GET /invoices/1/edit
  def edit
  end

  # POST /invoices
  # POST /invoices.json
  def create
    @invoice = Invoice.new(invoice_params)

    respond_to do |format|
      if @invoice.save
        @invoice.update_attributes(:sum => @invoice.payplan.price, :status => 'Не оплачен')
        @payment = Payment.create(:user_id => current_user.id, :invoice_id => @invoice.id, :payplan_id => @invoice.payplan.id, :status => 'Не оплачен', :paymenttype => @invoice.paymenttype)
        format.html { redirect_to @invoice, notice: 'Счет создан' }
        format.json { render :show, status: :created, location: @invoice }
      else
        format.html { render :new }
        format.json { render json: @invoice.errors, status: :unprocessable_entity }
      end
    end
  end

  # PATCH/PUT /invoices/1
  # PATCH/PUT /invoices/1.json
  def update
    respond_to do |format|
      if @invoice.update(invoice_params)
          @invoice.update_attributes(:sum => @invoice.payplan.price)
        format.html { redirect_to @invoice, notice: 'Счет обновлен.' }
        format.json { render :show, status: :ok, location: @invoice }
      else
        format.html { render :edit }
        format.json { render json: @invoice.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /invoices/1
  # DELETE /invoices/1.json
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
    # Use callbacks to share common setup or constraints between actions.
    def set_invoice
      @invoice = Invoice.find(params[:id])
    end

    # Never trust parameters from the scary internet, only allow the white list through.
    def invoice_params
      params.require(:invoice).permit(:payplan_id, :sum, :status, :payertype, :paymenttype)
    end
end
