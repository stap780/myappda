# Discount < ApplicationRecord
class Discount < ApplicationRecord
  acts_as_list

  validates :rule, uniqueness: true

  include ActionView::RecordIdentifier

  after_create_commit do
    broadcast_append_to [:discounts, Apartment::Tenant.current], target: "discounts_#{Apartment::Tenant.current}", partial: 'discounts/discount',locals: {discount: self}
  end
  after_update_commit do
    broadcast_replace_to [:discounts, Apartment::Tenant.current], target: dom_id(self, Apartment::Tenant.current), partial: 'discounts/discount',locals: {discount: self}
  end
  after_destroy_commit do
    broadcast_remove_to [:discounts, Apartment::Tenant.current], target: dom_id(self, Apartment::Tenant.current)
  end

  # this is for default use untill insales API start work
  RULES = [['2 товара','2_items'], ['3 товара','3_items']]

  def self.ransackable_attributes(auth_object = nil)
    attribute_names
  end


  def value
    "#{move} - #{shift} - #{points}"
  end

end
