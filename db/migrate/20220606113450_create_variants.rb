class CreateVariants < ActiveRecord::Migration[5.2]
  def change
    create_table :variants do |t|
      t.integer :insid
      t.string :sku
      t.integer :quantity
      t.decimal :price
      t.references :product, foreign_key: true

      t.timestamps
    end
  end
end
