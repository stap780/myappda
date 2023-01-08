class EmailSetupsController < ApplicationController
  before_action :authenticate_user!
  before_action :set_email_setup, only: [:show, :edit, :update, :destroy]

  # GET /email_setups
  def index
    #@email_setups = EmailSetup.all
    @search = EmailSetup.ransack(params[:q])
    @search.sorts = 'id asc' if @search.sorts.empty?
    @email_setups = @search.result.paginate(page: params[:page], per_page: 30)
  end

  # GET /email_setups/1
  def show
  end

  # GET /email_setups/new
  def new
    if EmailSetup.all.count < 1
      @email_setup = EmailSetup.new
    else
      redirect_to email_setups_url, notice: "You already have Email setup."
    end
  end

  # GET /email_setups/1/edit
  def edit
  end

  # POST /email_setups
  def create
    @email_setup = EmailSetup.new(email_setup_params)

    respond_to do |format|
      if @email_setup.save
        format.html { redirect_to email_setups_url, notice: "Email setup was successfully created." }
        format.json { render :show, status: :created, location: @email_setup }
      else
        format.html { render :new, status: :unprocessable_entity }
        format.json { render json: @email_setup.errors, status: :unprocessable_entity }
      end
    end
  end

  # PATCH/PUT /email_setups/1
  def update
  respond_to do |format|
    if @email_setup.update(email_setup_params)
      format.html { redirect_to email_setups_url, notice: "Email setup was successfully updated." }
      format.json { render :show, status: :ok, location: @email_setup }
    else
      format.html { render :edit, status: :unprocessable_entity }
      format.json { render json: @email_setup.errors, status: :unprocessable_entity }
    end
  end
  end

  # DELETE /email_setups/1
  def destroy
    @email_setup.destroy
    respond_to do |format|
      format.html { redirect_to email_setups_url, notice: "Email setup was successfully destroyed." }
      format.json { head :no_content }
    end
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_email_setup
      @email_setup = EmailSetup.find(params[:id])
    end

    # Only allow a trusted parameter "white list" through.
    def email_setup_params
      params.require(:email_setup).permit(:address, :port, :domain, :authentication, :user_name, :user_password, :tls)
    end
end
