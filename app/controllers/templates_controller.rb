class TemplatesController < ApplicationController
  before_action :authenticate_user!
  before_action :set_template, only: [:show, :edit, :update, :preview_ins_order, :preview_case, :preview_restock, :destroy]
  before_action :check_receiver, only: [:create, :update]

  # GET /templates
  def index
    #@templates = Template.all
    @search = Template.ransack(params[:q])
    @search.sorts = 'id asc' if @search.sorts.empty?
    @templates = @search.result.paginate(page: params[:page], per_page: 30)
  end

  # GET /templates/1
  def show
  end
  
  def preview_ins_order
    service = ApiInsales.new(current_user.insints.first)
    @order = service.order(params[:insales_order_id])
    @client = service.client(@order.client.id)
    respond_to do |format|
      format.js
    end
  end

  def preview_case
    @case = Case.find_by_id(params[:case_id])
    @client = @case.client
    respond_to do |format|
      format.js
    end
  end

  def preview_restock
    @client = Client.find_by_id(params[:client_id])
    respond_to do |format|
      format.js
    end
  end

  # GET /templates/new
  def new
    @template = Template.new
  end

  # GET /templates/1/edit
  def edit
    if Insint.present_work?
      service = ApiInsales.new(Insint.current)
      @ten_orders = service.ten_orders
    end
  end

  # POST /templates
  def create
    success, message = check_receiver
    @template = Template.new(template_params)
    if success
      respond_to do |format|
        if @template.save
          format.html { redirect_to edit_template_path(@template), notice: "Шаблон создан" }
          format.json { render :show, status: :created, location: @template }
        else
          format.html { render :new, status: :unprocessable_entity }
          format.json { render json: @template.errors, status: :unprocessable_entity }
        end
      end
    else
        flash.now[:notice] = message
        render :edit, status: :unprocessable_entity
    end
  end

  # PATCH/PUT /templates/1
  def update
    success, message = check_receiver

    service = ApiInsales.new(current_user.insints.first)
    @ten_orders = service.ten_orders
    @validate_title = params[:template][:title]
    @validate_subject = params[:template][:subject]
    @validate_receiver = params[:template][:receiver]
    @validate_content = params[:template][:content]
    if success
      respond_to do |format|
        if @template.update(template_params)
          flash.now[:notice] = "Шаблон обновлён"
          format.html { render :edit, notice: "Шаблон обновлён" }
          format.json { render :show, status: :ok, location: @template }
        else
          format.html { render :edit, status: :unprocessable_entity }
          format.json { render json: @template.errors, status: :unprocessable_entity }
        end
      end
    else
      flash.now[:notice] = message
      render :edit, status: :unprocessable_entity
    end
  end

  # DELETE /templates/1
  def destroy
    @template.destroy
    respond_to do |format|
      format.html { redirect_to templates_url, notice: "Template was successfully destroyed." }
      format.json { head :no_content }
    end
  end

# POST /templates
  def delete_selected
    @templates = Template.find(params[:ids])
    @templates.each do |template|
        template.destroy
    end
    respond_to do |format|
      format.html { redirect_to templates_url, notice: "Template was successfully destroyed." }
      format.json { render json: { :status => "ok", :message => "destroyed" } }
    end
  end


  private
    # Use callbacks to share common setup or constraints between actions.
  def set_template
    @template = Template.find(params[:id])
  end

    # Only allow a trusted parameter "white list" through.
  def template_params
    params.require(:template).permit(:title, :subject, :receiver, :content)
  end

  def check_receiver

    return [true,''] if params[:template][:receiver] == 'client'

    message = []
    emails = params[:template][:receiver].split(',')
    puts emails.size
    emails.each do |email|
      clear_email = email.squish if email.respond_to?(:squish)
      check = clear_email =~ URI::MailTo::EMAIL_REGEXP
      message.push("Email wrong") if check != 0
    end
    puts "message.uniq "+message.uniq.to_s

    message.uniq.size > 0 ? [false, message.uniq] : [true, message]

  end

end
