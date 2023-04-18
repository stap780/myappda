class RemoveColumnRestockTimeFromMessageSetups < ActiveRecord::Migration[5.2]
  def change
    remove_column :message_setups, :restock_time
  end
end
