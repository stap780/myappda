class AddColumnPayplanIdToFavoriteSetups < ActiveRecord::Migration[5.2]
  def change
    add_column :favorite_setups, :payplan_id, :integer
  end
end
