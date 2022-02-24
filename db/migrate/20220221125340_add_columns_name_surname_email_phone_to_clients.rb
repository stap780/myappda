class AddColumnsNameSurnameEmailPhoneToClients < ActiveRecord::Migration[5.2]
  def change
    add_column :clients, :name, :string
    add_column :clients, :surname, :string
    add_column :clients, :email, :string
    add_column :clients, :phone, :string
  end
end
