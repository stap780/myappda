class AddYaClientToClients < ActiveRecord::Migration[7.2]
  def change
    add_column :clients, :ya_client, :integer
  end
end
