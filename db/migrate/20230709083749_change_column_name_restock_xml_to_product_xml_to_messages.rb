class ChangeColumnNameRestockXmlToProductXmlToMessages < ActiveRecord::Migration[5.2]
  def change
    rename_column :message_setups, :restock_xml, :product_xml
  end
end
