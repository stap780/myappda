class AddColumnTypeToEvents < ActiveRecord::Migration[5.2]
  def change
    add_column :events, :casetype, :string
  end
end
