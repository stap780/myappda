json.extract! event_action, :id, :type, :event_id, :template_id, :pause, :pause_time, :timetable, :timetable_time, :created_at, :updated_at
json.url event_action_url(event_action, format: :json)
