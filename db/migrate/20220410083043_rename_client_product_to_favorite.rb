class RenameClientProductToFavorite < ActiveRecord::Migration[5.2]
  def change
    rename_table :client_products, :favorites
  end
end
