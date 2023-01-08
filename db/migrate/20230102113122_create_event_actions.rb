class CreateEventActions < ActiveRecord::Migration[5.2]
  def change
    create_table :event_actions do |t|
      t.string :type
      t.references :event, foreign_key: true
      t.references :template, foreign_key: true
      t.boolean :pause
      t.string :pause_time
      t.boolean :timetable
      t.string :timetable_time

      t.timestamps
    end
  end
end
