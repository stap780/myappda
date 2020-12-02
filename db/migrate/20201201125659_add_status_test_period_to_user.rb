class AddStatusTestPeriodToUser < ActiveRecord::Migration[5.2]
  def change
    add_column :users, :status_test_period, :boolean, default: true
  end
end
