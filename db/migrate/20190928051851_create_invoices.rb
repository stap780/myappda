class CreateInvoices < ActiveRecord::Migration[5.0]
  def change
    create_table :invoices do |t|
      t.integer :payplan_id
      t.string :sum
      t.string :status

      t.timestamps
    end
  end
end
