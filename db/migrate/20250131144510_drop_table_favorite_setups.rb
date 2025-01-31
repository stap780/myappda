class DropTableFavoriteSetups < ActiveRecord::Migration[7.1]
  def change
    drop_table :favorite_setups
  end
end
