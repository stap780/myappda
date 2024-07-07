class RenameTableCasesToMycases < ActiveRecord::Migration[7.1]
  def change
    rename_table :cases, :mycases
  end
end
