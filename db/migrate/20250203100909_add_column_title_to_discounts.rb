class AddColumnTitleToDiscounts < ActiveRecord::Migration[7.1]
  def change
    add_column :discounts, :title, :string
  end
end
