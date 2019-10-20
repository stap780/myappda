json.extract! invoice, :id, :payplan_id, :sum, :status, :created_at, :updated_at
json.url invoice_url(invoice, format: :json)
