class ChangeColumnNameTypeToEventActions < ActiveRecord::Migration[5.2]
  def change
    rename_column :event_actions, :type, :channel
  end
end
