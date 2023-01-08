class CreateOrderStatusChanges < ActiveRecord::Migration[5.2]
  def change
    create_table :order_status_changes do |t|
      t.integer :client_id
      t.integer :event_id
      t.integer :insales_order_id
      t.integer :insales_order_number
      t.string :insales_custom_status_title
      t.string :insales_financial_status

      t.timestamps
    end
  end
end
