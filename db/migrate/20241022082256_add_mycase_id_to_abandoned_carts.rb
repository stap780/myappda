class AddMycaseIdToAbandonedCarts < ActiveRecord::Migration[7.1]
  def change
    add_column :abandoned_carts, :mycase_id, :integer
  end
end
