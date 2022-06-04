class CreateItems < ActiveRecord::Migration[5.2]
  def change
    create_table :items do |t|
      t.string :title
      t.string :handle
      t.string :description
      t.boolean :status

      t.timestamps
    end
  end
end
