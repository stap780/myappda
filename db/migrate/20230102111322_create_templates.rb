class CreateTemplates < ActiveRecord::Migration[5.2]
  def change
    create_table :templates do |t|
      t.string :title
      t.string :subject
      t.string :receiver
      t.text :content

      t.timestamps
    end
  end
end
