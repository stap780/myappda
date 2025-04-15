class AbandonedCart < ApplicationRecord
  belongs_to :client
  belongs_to :mycase
  belongs_to :product
  belongs_to :variant
  validates_uniqueness_of :variant_id, scope: %i[client_id mycase_id]

  STATUS = [
    ['Ожидаем','wait'],
    ['Сформировано','ready'],
    ['Отправлено','send']
  ].freeze

  def self.ransackable_attributes(auth_object = nil)
    AbandonedCart.attribute_names
  end

end
