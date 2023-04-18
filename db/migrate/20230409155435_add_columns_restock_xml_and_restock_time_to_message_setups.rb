class AddColumnsRestockXmlAndRestockTimeToMessageSetups < ActiveRecord::Migration[5.2]
  def change
    add_column :message_setups, :restock_xml, :string
    add_column :message_setups, :restock_time, :string
  end
end
