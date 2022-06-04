class AddColumnValidUntilToFavoriteSetups < ActiveRecord::Migration[5.2]
  def change
    add_column :favorite_setups, :valid_until, :date
  end
end
