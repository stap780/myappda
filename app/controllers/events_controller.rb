class EventsController < ApplicationController
  before_action :authenticate_user!
  before_action :set_event, only: [:show, :edit, :update, :toggle_casetype, :destroy]

  # GET /events
  def index
    #@events = Event.all
    @search = Event.ransack(params[:q])
    @search.sorts = 'id desc' if @search.sorts.empty?
    @events = @search.result.paginate(page: params[:page], per_page: 30)
  end

  # GET /events/1
  def show
  end

  # GET /events/new
  def new
    @event = Event.new
    @event.event_actions.build
  end

  # GET /events/1/edit
  def edit
    @event.event_actions.build if !@event.event_actions.present?
  end

  # POST /events
  def create
    @event = Event.new(event_params)

    respond_to do |format|
      if @event.save
        format.html { redirect_to events_url, notice: "Event was successfully created." }
        format.json { render :show, status: :created, location: @event }
      else
        format.html { render :new, status: :unprocessable_entity }
        format.json { render json: @event.errors, status: :unprocessable_entity }
      end
    end
    # puts @event.errors.full_messages
  end

  # PATCH/PUT /events/1
  def update
    respond_to do |format|
      if @event.update(event_params)
        format.html { redirect_to events_url, notice: "Event was successfully updated." }
        format.json { render :show, status: :ok, location: @event }
      else
        format.html { render :edit, status: :unprocessable_entity }
        format.json { render json: @event.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /events/1
  def destroy
    @event.destroy
    respond_to do |format|
      format.html { redirect_to events_url, notice: "Event was successfully destroyed." }
      format.json { head :no_content }
    end
  end

# POST /events
  def delete_selected
    @events = Event.find(params[:ids])
    @events.each do |event|
        event.destroy
    end
    respond_to do |format|
      format.html { redirect_to events_url, notice: "Event was successfully destroyed." }
      format.json { render json: { :status => "ok", :message => "destroyed" } }
    end
  end

  def toggle_casetype
    @event = Event.find(params[:id])
    respond_to do |format|
      format.turbo_stream do
        render turbo_stream: turbo_stream.replace(
          dom_id(@event),
          partial: 'inboxes/inbox',
          locals: { inbox: @inbox }
        )
      end
    end
  end

  private
    def set_event
      @event = Event.find(params[:id])
    end

    # Only allow a trusted parameter "white list" through.
    def event_params
      params.require(:event).permit(:active, :custom_status, :financial_status, :casetype, event_actions_attributes: [:id, :channel, :event_id, :template_id, :pause, :pause_time, :timetable, :timetable_time, :operation])
    end
end
