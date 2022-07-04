class AddColumnStatusToRestocks < ActiveRecord::Migration[5.2]
  def change
    add_column :restocks, :status, :string
  end
end
