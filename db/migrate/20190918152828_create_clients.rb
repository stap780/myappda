class CreateClients < ActiveRecord::Migration[5.0]
  def change
    create_table :clients do |t|
      t.string :clientid
      t.string :izb_productid

      t.timestamps
    end
  end
end
