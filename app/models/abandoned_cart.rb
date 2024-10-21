class AbandonedCart < ApplicationRecord
  belongs_to :variant
  belongs_to :client
  belongs_to :product
  validates_uniqueness_of :variant_id, scope: :client_id

  def self.ransackable_attributes(auth_object = nil)
    AbandonedCart.attribute_names
  end

end
