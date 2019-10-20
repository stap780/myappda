class AddColumnPaymenttypeToPayments < ActiveRecord::Migration[5.0]
  def change
    add_column :payments, :paymenttype, :string
  end
end
