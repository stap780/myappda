class AddColumnCaseIdToLines < ActiveRecord::Migration[5.2]
  def change
    add_column :lines, :case_id, :integer
  end
end
