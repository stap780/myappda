class TemplatesController < ApplicationController
  before_action :authenticate_user!
  before_action :set_template, only: [:show, :edit, :update, :preview, :destroy]

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
  
  def preview
    service = Services::InsalesApi.new(current_user.insints.first)
    @order = service.order(params[:insales_order_id])
    @client = service.client(@order.client.id)
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
    service = Services::InsalesApi.new(current_user.insints.first)
    @ten_orders = service.ten_orders
  end

  # POST /templates
  def create
    @template = Template.new(template_params)

    respond_to do |format|
      if @template.save
        format.html { redirect_to templates_url, notice: "Template was successfully created." }
        format.json { render :show, status: :created, location: @template }
      else
        format.html { render :new, status: :unprocessable_entity }
        format.json { render json: @template.errors, status: :unprocessable_entity }
      end
    end

  end

  # PATCH/PUT /templates/1
  def update
    respond_to do |format|
      if @template.update(template_params)
        format.html { redirect_to templates_url, notice: "Template was successfully updated." }
        format.json { render :show, status: :ok, location: @template }
      else
        format.html { render :edit, status: :unprocessable_entity }
        format.json { render json: @template.errors, status: :unprocessable_entity }
      end
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
end
