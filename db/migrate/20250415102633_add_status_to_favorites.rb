class AddStatusToFavorites < ActiveRecord::Migration[7.2]
  def change
    add_column :favorites, :status, :string
  end
end
