class UseraccountsController < ApplicationController
  before_action :authenticate_user!
  before_action :set_useraccount, only: [:show, :edit, :update, :destroy]

  # GET /useraccounts
  # GET /useraccounts.json
  def index
    redirect_to dashboard_path
    # @useraccounts = Useraccount.all

    # invoice = Invoice.where(:status => "Оплачен").last
    # @pay_period = invoice.updated_at.to_date + invoice.payplan.period.split(' ')[0].to_i.months || '' if invoice.present?
  end

  # GET /useraccounts/1
  # GET /useraccounts/1.json
  def show
    redirect_to dashboard_path, alert: 'Access denied.' unless @user == current_user || current_admin
  end

  # GET /useraccounts/new
  def new
    @useraccount = Useraccount.new
    # redirect_to dashboard_path, alert: 'Access denied.' unless @user == current_user || current_admin
  end

  # GET /useraccounts/1/edit
  def edit
  end

  # POST /useraccounts
  # POST /useraccounts.json
  def create
    @useraccount = Useraccount.new(useraccount_params)

    respond_to do |format|
      if @useraccount.save
        format.turbo_stream { flash.now[:success] = t(".success") }
        format.html { redirect_to dashboard_path, notice: 'Пользователь was successfully created.' }
        format.json { render :show, status: :created, location: @useraccount }
      else
        format.html { render :new }
        format.json { render json: @useraccount.errors, status: :unprocessable_entity }
      end
    end
  end

  # PATCH/PUT /useraccounts/1
  # PATCH/PUT /useraccounts/1.json
  def update
    respond_to do |format|
      if @useraccount.update(useraccount_params)
        format.turbo_stream { flash.now[:success] = t(".success") }
        format.html { redirect_to dashboard_path, notice: 'Пользователь was successfully updated.' }
        format.json { render :show, status: :ok, location: @useraccount }
      else
        format.html { render :edit }
        format.json { render json: @useraccount.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /useraccounts/1
  # DELETE /useraccounts/1.json
  def destroy
    @useraccount.destroy
    respond_to do |format|
      format.html { redirect_to dashboard_path, notice: 'Пользователь was successfully destroyed.' }
      format.json { head :no_content }
    end
  end

  private
    def set_useraccount
      @useraccount = Useraccount.find(params[:id])
    end

    def useraccount_params
      params.require(:useraccount).permit(:name, :email, :shop, :insuserid, :user_id)
    end
end
