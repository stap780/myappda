class CreateAbandonedCarts < ActiveRecord::Migration[7.1]
  def change
    create_table :abandoned_carts do |t|
      t.references :variant, null: false, foreign_key: true
      t.references :client, null: false, foreign_key: true
      t.references :product, null: false, foreign_key: true
      t.text :status

      t.timestamps
    end
  end
end
