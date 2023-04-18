class AddColumnProductIdToRestocks < ActiveRecord::Migration[5.2]
  def change
    add_column :restocks, :product_id, :integer
  end
end
