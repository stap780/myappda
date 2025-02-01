# Company < ApplicationRecord
class Company < ApplicationRecord

  def self.ransackable_attributes(auth_object = nil)
    attribute_names
  end

end
