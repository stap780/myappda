class CreateCompanies < ActiveRecord::Migration[5.0]
  def change
    create_table :companies do |t|
      t.string :inn
      t.string :kpp
      t.string :title
      t.string :uraddress
      t.string :factaddress
      t.string :ogrn
      t.string :okpo
      t.string :bik
      t.string :banktitle
      t.string :bankaccount

      t.timestamps
    end
  end
end
