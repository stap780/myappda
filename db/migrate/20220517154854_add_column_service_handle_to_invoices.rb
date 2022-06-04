class AddColumnServiceHandleToInvoices < ActiveRecord::Migration[5.2]
  def change
    add_column :invoices, :service_handle, :string
  end
end
