json.extract! payment, :id, :user_id, :invoice_id, :payplan_id, :status, :created_at, :updated_at
json.url payment_url(payment, format: :json)
