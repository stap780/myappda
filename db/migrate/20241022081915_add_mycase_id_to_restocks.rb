class AddMycaseIdToRestocks < ActiveRecord::Migration[7.1]
  def change
    add_reference :restocks, :mycase, null: false, foreign_key: true
  end
end
