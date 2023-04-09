class AddColumnsToCases < ActiveRecord::Migration[5.2]
  def change
    add_column :cases, :insales_custom_status_title, :string
    add_column :cases, :insales_financial_status, :string
    add_column :cases, :insales_order_id, :integer
    add_column :cases, :status, :string
  end
end
