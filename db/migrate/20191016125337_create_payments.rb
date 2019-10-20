class CreatePayments < ActiveRecord::Migration[5.0]
  def change
    create_table :payments do |t|
      t.integer :user_id
      t.integer :invoice_id
      t.integer :payplan_id
      t.string :status

      t.timestamps
    end
  end
end
