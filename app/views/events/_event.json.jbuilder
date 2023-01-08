json.extract! event, :id, :custom_status, :financial_status, :created_at, :updated_at
json.url event_url(event, format: :json)
