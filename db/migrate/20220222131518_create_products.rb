class CreateProducts < ActiveRecord::Migration[5.2]
  def change
    create_table :products do |t|
      t.integer :insid
      t.string :title
      t.decimal :price, precision: 8, scale: 2

      t.timestamps
    end
  end
end
