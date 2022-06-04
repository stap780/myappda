class AddColumnsTitleDescriptionServiceHandleToPayplans < ActiveRecord::Migration[5.2]
  def change
    add_column :payplans, :title, :string
    add_column :payplans, :description, :string
    add_column :payplans, :service_handle, :string
  end
end
