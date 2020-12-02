class PaymentsController < ApplicationController
  before_action :authenticate_user! , except: [:success, :fail, :result]
  before_action :set_payment, only: [:show, :edit, :update, :destroy]
  protect_from_forgery with: :null_session
  skip_before_action :redirect_to_subdomain

  authorize_resource

  # GET /payments
  # GET /payments.json
  def index
    # @payments = Payment.all
    @search = Payment.ransack(params[:q])
    @search.sorts = 'id desc' if @search.sorts.empty?
    @payments = @search.result.paginate(page: params[:page], per_page: 30)
  end

  # GET /payments/1
  # GET /payments/1.json
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
  # POST /payments.json
  def create
    @payment = Payment.new(payment_params)

    respond_to do |format|
      if @payment.save
        format.html { redirect_to @payment, notice: 'Payment was successfully created.' }
        format.json { render :show, status: :created, location: @payment }
      else
        format.html { render :new }
        format.json { render json: @payment.errors, status: :unprocessable_entity }
      end
    end
  end

  # PATCH/PUT /payments/1
  # PATCH/PUT /payments/1.json
  def update
    respond_to do |format|
      if @payment.update(payment_params)
        if @payment.status == 'Оплачен'
          old_valid_until = @payment.user.valid_until # || Date.today
          add_period = @payment.payplan.period.split(' ')[0]
          new_valid_until = old_valid_until + "#{add_period}".to_i.months
          @payment.user.update_attributes(valid_until: new_valid_until)
          Apartment::Tenant.switch!(@payment.user.subdomain)
          invoice = Invoice.find(@payment.invoice_id)
          invoice.update_attributes(:status => 'Оплачен', :payplan_id => @payment.payplan_id, :sum => @payment.payplan.price)
        else
          Apartment::Tenant.switch!(@payment.user.subdomain)
          invoice = Invoice.find(@payment.invoice_id)
          invoice.update_attributes(:status => 'Не оплачен', :payplan_id => @payment.payplan_id, :sum => @payment.payplan.price)
        end
        format.html { redirect_to @payment, notice: 'Payment was successfully updated.' }
        format.json { render :show, status: :ok, location: @payment }
      else
        format.html { render :edit }
        format.json { render json: @payment.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /payments/1
  # DELETE /payments/1.json
  def destroy
    @payment.destroy
    respond_to do |format|
      format.html { redirect_to payments_url, notice: 'Payment was successfully destroyed.' }
      format.json { head :no_content }
    end
  end

  def result
    puts 'result here'
    @payments = Payment.where(:user_id => params['CURRENT_USER'], :invoice_id => params['LMI_PAYMENT_NO'] )
    @payments.each do |payment|
      payment.update_attributes(:status => 'Оплачен', :paymentdate => params['LMI_SYS_PAYMENT_DATE'], :paymentid => params['LMI_SYS_PAYMENT_ID'] )
      user = User.find(params['CURRENT_USER'])
      old_valid_until = user.valid_until
      add_period = payment.payplan.period.split(' ')[0]
      new_valid_until = old_valid_until + "#{add_period}".to_i.months
      user.update_attributes(valid_until: new_valid_until)
    end
    head :ok
  end

  def success
    puts 'success here'
    @user = User.find(params[:CURRENT_USER])
    Apartment::Tenant.switch!(@user.subdomain)
    invoice = Invoice.find(params[:LMI_PAYMENT_NO])
    invoice.update_attributes(:status => 'Оплачен')
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
