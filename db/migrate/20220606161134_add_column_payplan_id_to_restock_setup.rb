class AddColumnPayplanIdToRestockSetup < ActiveRecord::Migration[5.2]
  def change
    add_column :restock_setups, :payplan_id, :integer
  end
end
