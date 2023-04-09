class CreateCases < ActiveRecord::Migration[5.2]
  def change
    create_table :cases do |t|
      t.string :number
      t.integer :client_id
      t.string :casetype

      t.timestamps
    end
  end
end
