class AddColumnCreatedAtToFavorites < ActiveRecord::Migration[5.2]
  def change
    # add_column :favorites, :created_at, :datetime, null: false
    add_timestamps :favorites, default: DateTime.now
  end
end
