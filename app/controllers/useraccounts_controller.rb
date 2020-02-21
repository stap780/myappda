class UseraccountsController < ApplicationController

  before_action :set_useraccount, only: [:show, :edit, :update, :destroy]

  # GET /useraccounts
  # GET /useraccounts.json
  def index
    @useraccounts = Useraccount.all
    insint = current_user.insints.first
    if insint.present?
      if insint.inskey.present?
        uri = "http://"+"#{insint.inskey}"+":"+"#{insint.password}"+"@"+"#{insint.subdomen}"+"/admin/account.json"
      else
        uri = "http://k-comment:"+"#{insint.password}"+"@"+"#{insint.subdomen}"+"/admin/account.json"
      end
        # puts uri
        response = RestClient.get(uri)
        data = JSON.parse(response)
        @ins_title = data['title']
        @ins_phone = data['phone']

    end

    invoice = Invoice.where(:status => "Оплачен").last
    @pay_period = invoice.updated_at.to_date + invoice.payplan.period.split(' ')[0].to_i.months || '' if invoice.present?
  end

  # GET /useraccounts/1
  # GET /useraccounts/1.json
  def show
  end

  # GET /useraccounts/new
  def new
    @useraccount = Useraccount.new
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
        format.html { redirect_to @useraccount, notice: 'Useraccount was successfully created.' }
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
        format.html { redirect_to @useraccount, notice: 'Useraccount was successfully updated.' }
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
      format.html { redirect_to useraccounts_url, notice: 'Useraccount was successfully destroyed.' }
      format.json { head :no_content }
    end
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_useraccount
      @useraccount = Useraccount.find(params[:id])
    end

    # Never trust parameters from the scary internet, only allow the white list through.
    def useraccount_params
      params.require(:useraccount).permit(:name, :email, :shop, :insuserid, :user_id)
    end
end
