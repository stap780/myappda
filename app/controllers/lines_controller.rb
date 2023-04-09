class LinesController < ApplicationController
  before_action :authenticate_user!
  before_action :set_line, only: [:show, :edit, :update, :destroy]

  # GET /lines
  def index
    #@lines = Line.all
    @search = Line.all.ransack(params[:q])
    @search.sorts = 'id asc' if @search.sorts.empty?
    @lines = @search.result.paginate(page: params[:page], per_page: 30)
  end

  # GET /lines/1
  def show
  end

  # GET /lines/new
  def new
    @line = Line.new
  end

  # GET /lines/1/edit
  def edit
  end

  # POST /lines
  def create
    @line = Line.new(line_params)

    respond_to do |format|
      if @line.save
        format.html { redirect_to @line, notice: "Line was successfully created." }
        format.json { render :show, status: :created, location: @line }
      else
        format.html { render :new, status: :unprocessable_entity }
        format.json { render json: @line.errors, status: :unprocessable_entity }
      end
    end

  end

  # PATCH/PUT /lines/1
  def update
  respond_to do |format|
    if @line.update(line_params)
      format.html { redirect_to @line, notice: "Line was successfully updated." }
      format.json { render :show, status: :ok, location: @line }
    else
      format.html { render :edit, status: :unprocessable_entity }
      format.json { render json: @line.errors, status: :unprocessable_entity }
    end
  end
  end

  # DELETE /lines/1
  def destroy
  @line.destroy
  respond_to do |format|
    format.html { redirect_to lines_url, notice: "Line was successfully destroyed." }
    format.json { head :no_content }
  end
  end

# POST /lines
  def delete_selected
    @lines = Line.find(params[:ids])
    @lines.each do |line|
        line.destroy
    end
    respond_to do |format|
      format.html { redirect_to lines_url, notice: "Line was successfully destroyed." }
      format.json { render json: { :status => "ok", :message => "destroyed" } }
    end
  end


  private
    # Use callbacks to share common setup or constraints between actions.
    def set_line
      @line = Line.find(params[:id])
    end

    # Only allow a trusted parameter "white list" through.
    def line_params
        params.require(:line).permit(:product_id, :variant_id, :quantity, :price)
    end
end
