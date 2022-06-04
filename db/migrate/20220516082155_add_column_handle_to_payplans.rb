class AddColumnHandleToPayplans < ActiveRecord::Migration[5.2]
  def change
    add_column :payplans, :handle, :string
  end
end
