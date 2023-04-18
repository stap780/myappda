class AddColumnRestockToProducts < ActiveRecord::Migration[5.2]
  def change
    add_column :products, :restock, :boolean
  end
end
