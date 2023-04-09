class CreateLines < ActiveRecord::Migration[5.2]
  def change
    create_table :lines do |t|
      t.integer :product_id
      t.integer :variant_id
      t.integer :quantity
      t.decimal :price

      t.timestamps
    end
  end
end
