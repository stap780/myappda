class AddColumnValidUntilToRestockSetups < ActiveRecord::Migration[5.2]
  def change
    add_column :restock_setups, :valid_until, :date
  end
end
