class AddColumnOperationToEventActions < ActiveRecord::Migration[5.2]
  def change
    add_column :event_actions, :operation, :string
  end
end
