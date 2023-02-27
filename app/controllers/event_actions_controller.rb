class EventActionsController < ApplicationController
  before_action :authenticate_user!
  before_action :set_event_action, only: [:show, :edit, :update, :destroy]

  # GET /event_actions
  def index
    #@event_actions = EventAction.all
    @search = EventAction.all.ransack(params[:q])
    @search.sorts = 'id asc' if @search.sorts.empty?
    @event_actions = @search.result.paginate(page: params[:page], per_page: 30)
  end

  # GET /event_actions/1
  def show
  end

  # GET /event_actions/new
  def new
    @event_action = EventAction.new
  end

  # GET /event_actions/1/edit
  def edit
  end

  # POST /event_actions
  def create
    @event_action = EventAction.new(event_action_params)

    respond_to do |format|
      if @event_action.save
        format.html { redirect_to @event_action, notice: "Event action was successfully created." }
        format.json { render :show, status: :created, location: @event_action }
      else
        format.html { render :new, status: :unprocessable_entity }
        format.json { render json: @event_action.errors, status: :unprocessable_entity }
      end
    end

  end

  # PATCH/PUT /event_actions/1
  def update
  respond_to do |format|
    if @event_action.update(event_action_params)
      format.html { redirect_to @event_action, notice: "Event action was successfully updated." }
      format.json { render :show, status: :ok, location: @event_action }
    else
      format.html { render :edit, status: :unprocessable_entity }
      format.json { render json: @event_action.errors, status: :unprocessable_entity }
    end
  end
  end

  # DELETE /event_actions/1
  def destroy
  @event_action.destroy
  respond_to do |format|
    format.html { redirect_to event_actions_url, notice: "Event action was successfully destroyed." }
    format.json { head :no_content }
  end
  end

# POST /event_actions
  def delete_selected
    @event_actions = Event Action.find(params[:ids])
    @event_actions.each do |event_action|
        event_action.destroy
    end
    respond_to do |format|
      format.html { redirect_to event_actions_url, notice: "Event action was successfully destroyed." }
      format.json { render json: { :status => "ok", :message => "destroyed" } }
    end
  end


  private
    # Use callbacks to share common setup or constraints between actions.
    def set_event_action
      @event_action = EventAction.find(params[:id])
    end

    # Only allow a trusted parameter "white list" through.
    def event_action_params
      params.require(:event_action).permit(:channel, :event_id, :template_id, :pause, :pause_time, :timetable, :timetable_time, :operation)
    end
end
