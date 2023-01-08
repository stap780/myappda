class CreateEmailSetups < ActiveRecord::Migration[5.2]
  def change
    create_table :email_setups do |t|
      t.string :address
      t.integer :port
      t.string :domain
      t.string :authentication
      t.string :user_name
      t.string :user_password
      t.boolean :tls

      t.timestamps
    end
  end
end
