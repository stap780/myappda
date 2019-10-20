class AddColumnsPayertypeAndPymenttypeToInvoices < ActiveRecord::Migration[5.0]
  def change
    add_column :invoices, :payertype, :string
    add_column :invoices, :paymenttype, :string
  end
end
