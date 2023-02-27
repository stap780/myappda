class DropEventOrderStatusChange < ActiveRecord::Migration[5.2]
  def change
    drop_table :event_order_status_changes
  end
end
