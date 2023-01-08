json.extract! message_setup, :id, :title, :handle, :description, :status, :payplan_id, :valid_until, :created_at, :updated_at
json.url message_setup_url(message_setup, format: :json)
