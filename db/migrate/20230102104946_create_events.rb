class CreateEvents < ActiveRecord::Migration[5.2]
  def change
    create_table :events do |t|
      t.string :custom_status
      t.string :financial_status

      t.timestamps
    end
  end
end
