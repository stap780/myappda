json.extract! line, :id, :product_id, :variant_id, :quantity, :price, :created_at, :updated_at
json.url line_url(line, format: :json)
