class AddSubdomainToPayments < ActiveRecord::Migration[5.2]
  def change
    add_column :payments, :subdomain, :string
  end
end
