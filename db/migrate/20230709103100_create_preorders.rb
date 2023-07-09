class CreatePreorders < ActiveRecord::Migration[5.2]
  def change
    create_table :preorders do |t|
      t.integer :variant_id
      t.integer :client_id
      t.string :status
      t.integer :product_id

      t.timestamps
    end
  end
end
