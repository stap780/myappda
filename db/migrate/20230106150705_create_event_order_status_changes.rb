class CreateEventOrderStatusChanges < ActiveRecord::Migration[5.2]
  def change
    create_table :event_order_status_changes do |t|
      t.integer :event_id
      t.integer :order_status_change_id

      t.timestamps
    end
  end
end
