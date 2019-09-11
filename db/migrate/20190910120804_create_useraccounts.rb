class CreateUseraccounts < ActiveRecord::Migration[5.0]
  def change
    create_table :useraccounts do |t|
      t.string :name
      t.string :email
      t.string :shop
      t.string :insuserid

      t.timestamps
    end
  end
end
