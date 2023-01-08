class CreateMessageSetups < ActiveRecord::Migration[5.2]
  def change
    create_table :message_setups do |t|
      t.string :title
      t.string :handle
      t.string :description
      t.boolean :status
      t.integer :payplan_id
      t.date :valid_until

      t.timestamps
    end
  end
end
