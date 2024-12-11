# frozen_string_literal: true

# Restock class
class Restock < ApplicationRecord
  belongs_to :product
  belongs_to :variant
  belongs_to :client
  belongs_to :mycase
  before_save :set_status_if_new_record
  validates_uniqueness_of :variant_id, scope: %i[client_id mycase_id]

  Status = [['Ждём поступления', 'wait'], ['Появился', 'ready'], ['Сообщение отправлено', 'send']].freeze

  scope :for_inform, -> { where(status: 'ready') }
  scope :status_wait, -> { where(status: 'wait') }

  def self.ransackable_attributes(auth_object = nil)
    Restock.attribute_names
  end

  def self.find_dups
    columns_that_make_record_distinct = %i[client_id variant_id mycase_id]
    Restock.select('MIN(id) as id').group(columns_that_make_record_distinct).map(&:id)
  end

  private

  def set_status_if_new_record
    self.status = 'wait' if new_record?
  end
end
# <Restock id: 4, variant_id: 2, client_id: 28, created_at: "2022-06-12 12:52:08", updated_at: "2022-06-12 12:52:08", status: "Ждём поступления", product_id: nil>
