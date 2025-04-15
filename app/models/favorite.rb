# Favorite < ApplicationRecord
class Favorite < ApplicationRecord

  belongs_to :client
  belongs_to :product
  validates_uniqueness_of :product_id, scope: :client_id

  STATUS = [
    ['Ожидаем','wait'],
    ['Сформировано','ready'],
    ['Отправлено','send']
  ].freeze

  def self.ransackable_attributes(auth_object = nil)
    Favorite.attribute_names
  end

  def self.find_dups
    columns_that_make_record_distinct = %i[client_id product_id]
    Favorite.select('MIN(id) as id').group(columns_that_make_record_distinct).map(&:id)
  end

end
