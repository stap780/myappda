class RenameColumnCaseIdToMycaseIdLines < ActiveRecord::Migration[7.1]
  def change
    rename_column :lines, :case_id, :mycase_id
  end
end
