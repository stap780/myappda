class CreateDiscounts < ActiveRecord::Migration[7.1]
  def change
    create_table :discounts do |t|
      t.string :rule
      t.string :move
      t.string :shift
      t.string :points
      t.string :notice
      t.integer :position, default: 1, null: false

      t.timestamps
    end
  end
end
