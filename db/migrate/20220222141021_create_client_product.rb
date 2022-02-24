class CreateClientProduct < ActiveRecord::Migration[5.2]
  def change
    create_table :client_products do |t|
      t.references :client, foreign_key: true
      t.references :product, foreign_key: true
    end
  end
end
