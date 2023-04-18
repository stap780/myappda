class AddColumnRestockToVariants < ActiveRecord::Migration[5.2]
  def change
    add_column :variants, :restock, :boolean
  end
end
