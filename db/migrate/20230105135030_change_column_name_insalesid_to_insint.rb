class ChangeColumnNameInsalesidToInsint < ActiveRecord::Migration[5.2]
  def change
    rename_column :insints, :insalesid, :insales_account_id
  end
end
