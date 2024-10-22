class AddMycaseIdToRestocks < ActiveRecord::Migration[7.1]
  def change
    add_column :restocks, :mycase_id, :integer
  end
end
