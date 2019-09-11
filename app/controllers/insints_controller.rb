class InsintsController < ApplicationController
  before_action :authenticate_user! , except: [:install, :uninstall, :login]
  before_action :set_insint, only: [:show, :edit, :update, :destroy]

  # GET /insints
  # GET /insints.json
  def index
    @insints = current_user.insints
  end

  # GET /insints/1
  # GET /insints/1.json
  def show
  end

  # GET /insints/new
  def new
    @insint = Insint.new
  end

  # GET /insints/1/edit
  def edit
  end

  # POST /insints
  # POST /insints.json
  def create
    @insint = Insint.new(insint_params)

    respond_to do |format|
      if @insint.save
        format.html { redirect_to @insint, notice: 'Insint was successfully created.' }
        format.json { render :show, status: :created, location: @insint }
      else
        format.html { render :new }
        format.json { render json: @insint.errors, status: :unprocessable_entity }
      end
    end
  end

  # PATCH/PUT /insints/1
  # PATCH/PUT /insints/1.json
  def update
    respond_to do |format|
      if @insint.update(insint_params)
        format.html { redirect_to @insint, notice: 'Insint was successfully updated.' }
        format.json { render :show, status: :ok, location: @insint }
      else
        format.html { render :edit }
        format.json { render json: @insint.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /insints/1
  # DELETE /insints/1.json
  def destroy
    @insint.destroy
    respond_to do |format|
      format.html { redirect_to insints_url, notice: 'Insint was successfully destroyed.' }
      format.json { head :no_content }
    end
  end

  def install
    puts params[:insales_id]
    @insint = Insint.find_by_insalesid(params[:insales_id])
    if @insint.present?
      puts "есть пользователь insint"
    else
      save_subdomain = "insales"+params[:insales_id]
      email = save_subdomain+"@mail.ru"
      puts save_subdomain
      user = User.create(:name => params[:insales_id], :subdomain => save_subdomain, :password => save_subdomain, :password_confirmation => save_subdomain, :email => email)
      puts user.id
      secret_key = 'my_test_secret_key'
      password = Digest::MD5.hexdigest(params[:token] + secret_key)
      Insint.create(:subdomen => params[:shop],  password: password, insalesid: params[:insales_id], :user_id => user.id)
      head :ok
    end
  end

  def uninstall
    @insint = Insint.find_by_insalesid(params[:insales_id])
    saved_subdomain = "insales"+params[:insales_id]
    @user = User.find_by_subdomain(saved_subdomain)
    if @insint.present?
      puts "удаляем пользователя insint - ""#{@insint.id}"
      @insint.delete
      @user.delete
      Apartment::Tenant.drop(saved_subdomain)
      head :ok
    end
  end

  def login
    @insint = Insint.find_by_insalesid(params[:insales_id])
    saved_subdomain = "insales"+params[:insales_id]
    Apartment::Tenant.switch!(saved_subdomain)
    @user = User.find_by_subdomain(saved_subdomain)
    if @user.present?
      if @insint.present?
        user_account = Useraccount.find_by_insuserid(params[:user_id])
        if user_account.present?
          name = params[:user_id]+params[:shop]
          user_account.update_attributes(:shop => params[:shop], :email => params[:user_email], :insuserid => params[:user_id], :name => name)
          sign_in(:user, @user)
          redirect_to after_sign_in_path_for(@user)
        else
          name = params[:user_id]+params[:shop]
          user_account = Useraccount.create(:shop => params[:shop], :email => params[:user_email], :insuserid => params[:user_id], :name => name)
          sign_in(:user, @user)
          redirect_to after_sign_in_path_for(@user)
        end
      end
    end
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_insint
      @insint = Insint.find(params[:id])
    end

    # Never trust parameters from the scary internet, only allow the white list through.
    def insint_params
      params.require(:insint).permit(:subdomen, :password, :insalesid, :user_id)
    end
end
