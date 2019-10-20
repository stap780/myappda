class AddColumnPaymentdatePaymentidToPayments < ActiveRecord::Migration[5.0]
  def change
    add_column :payments, :paymentdate, :datetime
    add_column :payments, :paymentid, :string
  end
end
