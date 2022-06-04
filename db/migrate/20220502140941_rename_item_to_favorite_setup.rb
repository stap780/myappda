class RenameItemToFavoriteSetup < ActiveRecord::Migration[5.2]
  def change
    rename_table :items, :favorite_setups
  end
end
