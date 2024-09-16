class UseraccountsController < ApplicationController
  before_action :authenticate_user!
  before_action :set_useraccount, only: [:show, :edit, :update, :destroy]

  def index
    redirect_to dashboard_path
  end

  def show
    redirect_to dashboard_path, alert: 'Access denied.' unless @user == current_user || current_admin
  end

  def new
    @useraccount = Useraccount.new
    # redirect_to dashboard_path, alert: 'Access denied.' unless @user == current_user || current_admin
  end

  def edit
  end

  def create
    @useraccount = Useraccount.new(useraccount_params)

    respond_to do |format|
      if @useraccount.save
        flash.now[:success] = t(".success")
        format.turbo_stream do
          render turbo_stream: [
            turbo_stream.update(Useraccount.new, ''),
            render_turbo_flash
          ]
        end
        format.html { redirect_to dashboard_path, notice: 'Пользователь was successfully created.' }
        format.json { render :show, status: :created, location: @useraccount }
      else
        format.html { render :new }
        format.json { render json: @useraccount.errors, status: :unprocessable_entity }
      end
    end
  end

  def update
    respond_to do |format|
      if @useraccount.update(useraccount_params)
        flash.now[:success] = t(".success")
        format.turbo_stream do
          render turbo_stream: [
            render_turbo_flash
          ]
        end
        format.html { redirect_to dashboard_path, notice: 'Пользователь was successfully updated.' }
        format.json { render :show, status: :ok, location: @useraccount }
      else
        format.html { render :edit }
        format.json { render json: @useraccount.errors, status: :unprocessable_entity }
      end
    end
  end

  def destroy
    @useraccount.destroy
    respond_to do |format|
      format.turbo_stream { flash.now[:success] = t(".success") }
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
