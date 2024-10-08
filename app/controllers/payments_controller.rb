class PaymentsController < ApplicationController
  before_action :authenticate_user! , except: [:success, :fail, :result]
  before_action :authenticate_admin!, only: [:index, :new, :create, :update, :destroy]
  before_action :set_payment, only: [:show, :edit, :update, :destroy]
  protect_from_forgery with: :null_session
  # skip_before_action :redirect_to_subdomain

  # GET /payments
  def index
    # @payments = Payment.all
    @search = Payment.ransack(params[:q])
    @search.sorts = 'id desc' if @search.sorts.empty?
    @payments = @search.result.paginate(page: params[:page], per_page: 50)
  end

  # GET /payments/1
  def show
  end

  # GET /payments/new
  def new
    @payment = Payment.new
  end

  # GET /payments/1/edit
  def edit
  end

  # POST /payments
  def create
    @payment = Payment.new(payment_params)
    
    respond_to do |format|
      if @payment.save
        flash[:notice] = "Payment was successfully created."
        format.html { redirect_to @payment}
        format.json { render :show, status: :created, location: @payment }
      else
        format.html { render :new }
        format.json { render json: @payment.errors, status: :unprocessable_entity }
      end
    end
  end

  # PATCH/PUT /payments/1
  def update
    respond_to do |format|
      if @payment.update(payment_params)
        format.html { redirect_to payments_url, notice: 'Payment was successfully updated.'}
        format.json { render :show, status: :ok, location: @payment }
      else
        format.html { render :edit }
        format.json { render json: @payment.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /payments/1
  def destroy
    @payment.destroy_invoice
    @payment.destroy
    respond_to do |format|
      format.html { redirect_to payments_url, notice: 'Payment was successfully destroyed.' }
      format.json { head :no_content }
    end
  end

  def result
    puts 'payment result here'
    payment = Payment.where(:user_id => params['CURRENT_USER'], :invoice_id => params['LMI_PAYMENT_NO'] ).take
    payment.update!(:status => 'Оплачен', :paymentdate => params['LMI_SYS_PAYMENT_DATE'], :paymentid => params['LMI_SYS_PAYMENT_ID'] ) if payment.present?
    head :ok
  end

  def success
    puts 'success here'
    @user = User.find(params[:CURRENT_USER])
    payment = Payment.where(:user_id => params['CURRENT_USER'], :invoice_id => params['LMI_PAYMENT_NO'] ).take
    payment.update!(:status => 'Оплачен', :paymentdate => params['LMI_SYS_PAYMENT_DATE'], :paymentid => params['LMI_SYS_PAYMENT_ID'] ) if payment.present?
    
    # switch off invoice update because have callback for update in payment
    # Apartment::Tenant.switch(@user.subdomain) do
    #   invoice = Invoice.find(params[:LMI_PAYMENT_NO])
    #   invoice.update!(status: 'Оплачен')
    # end
    
    sign_in(:user, @user)
    redirect_to after_sign_in_path_for(@user)
  end

  def fail
    puts 'fail here'
    @user = User.find(params[:CURRENT_USER])
    Apartment::Tenant.switch!(@user.subdomain)
    sign_in(:user, @user)
    redirect_to after_sign_in_path_for(@user)
  end

  def delete_selected
    @payments = Payment.find(params[:ids])
    @payments.each do |payment|
      payment.destroy
    end
    respond_to do |format|
      # format.html { redirect_to payments_url, notice: "was successfully destroyed." }
      format.json { render json: { :status => "ok", :message => "destroyed" } }
    end
  end


  private
    # Use callbacks to share common setup or constraints between actions.
    def set_payment
      @payment = Payment.find(params[:id])
    end

    # Never trust parameters from the scary internet, only allow the white list through.
    def payment_params
      params.require(:payment).permit(:user_id, :invoice_id, :payplan_id, :status, :paymenttype, :paymentdate, :paymentid)
    end
end
