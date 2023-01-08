json.extract! order_status_change, :id, :client_id, :event_id, :insales_order_id, :insales_order_number, :insales_custom_status_title, :insales_financial_status, :created_at, :updated_at
json.url order_status_change_url(order_status_change, format: :json)
