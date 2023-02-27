class RemoveColumnEventIdFromOrderStatusChange < ActiveRecord::Migration[5.2]
  def change
    remove_column :order_status_changes, :event_id, :integer
  end
end
