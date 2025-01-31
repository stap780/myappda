class RemoveColumnsIzbProductidFromClients < ActiveRecord::Migration[7.1]
  def change
    remove_column :clients, :izb_productid, :string
  end
end
