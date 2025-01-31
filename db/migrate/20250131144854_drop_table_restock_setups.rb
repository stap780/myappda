class DropTableRestockSetups < ActiveRecord::Migration[7.1]
  def change
    drop_table :restock_setups
  end
end
