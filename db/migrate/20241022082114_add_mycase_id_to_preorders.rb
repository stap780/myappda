class AddMycaseIdToPreorders < ActiveRecord::Migration[7.1]
  def change
    add_column :preorders, :mycase_id, :integer
  end
end
