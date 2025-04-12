# The EventsController is responsible for managing the lifecycle of Event objects.
class EventsController < ApplicationController
  before_action :authenticate_user!
  before_action :set_event, only: %i[show edit update toggle_casetype destroy]
  before_action :validate_pause_time, only: %i[create update]


  def index
    @search = Event.ransack(params[:q])
    @search.sorts = 'id desc' if @search.sorts.empty?
    @events = @search.result.paginate(page: params[:page], per_page: 30)
  end

  def show; end

  def new
    @event = Event.new
    @event.event_actions.build
  end

  def edit
    @event.event_actions.build unless @event.event_actions.present?
  end

  def create
    @event = Event.new(event_params)
    success, message = validate_pause_time
    if success
      respond_to do |format|
        if @event.save
          format.html { redirect_to events_url, notice: t(:success) }
          format.json { render :show, status: :created, location: @event }
        else
          format.html { render :new, status: :unprocessable_entity }
          format.json { render json: @event.errors, status: :unprocessable_entity }
        end
      end
    else
      flash.now[:notice] = message
      render :new, status: :unprocessable_entity
    end
    # puts @event.errors.full_messages
  end

  def update
    success, message = validate_pause_time
    if success
      respond_to do |format|
        if @event.update(event_params)
          format.html { redirect_to events_url, notice: t(:success) }
          format.json { render :show, status: :ok, location: @event }
        else
          format.html { render :edit, status: :unprocessable_entity }
          format.json { render json: @event.errors, status: :unprocessable_entity }
        end
      end
    else
      flash.now[:notice] = message
      render :edit, status: :unprocessable_entity
    end
  end

  def destroy
    @event.destroy
    respond_to do |format|
      format.html { redirect_to events_url, notice: t(:success) }
      format.json { head :no_content }
    end
  end

  def delete_selected
    @events = Event.find(params[:ids])
    @events.each do |event|
      event.destroy
    end
    respond_to do |format|
      format.html { redirect_to events_url, notice: t(:success) }
      format.json { render json: { status: 'ok', message: 'destroyed' } }
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

  def event_params
    params.require(:event).permit(:active, :custom_status, :financial_status, :casetype, event_actions_attributes: [:id, :channel, :event_id, :template_id, :pause, :pause_time, :timetable, :timetable_time, :operation])
  end

  def validate_pause_time
    message = []
    return unless params[:event][:event_actions_attributes].present?

    notice = 'Укажите время задержки'
    params[:event][:event_actions_attributes].each_value do |action|
      message.push(notice) if action[:pause] == '1' && action[:pause_time].blank?
      message.push(notice) if action[:timetable] == '1' && action[:timetable_time].blank?
    end
    message.present? ? [false, message.join(' ')] : [true, '']
  end
end
