class CreateRestocks < ActiveRecord::Migration[5.2]
  def change
    create_table :restocks do |t|
      t.references :variant, foreign_key: true
      t.references :client, foreign_key: true

      t.timestamps
    end
  end
end
