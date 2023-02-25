class Favorite < ApplicationRecord
  default_scope { order(id: :desc) }
  belongs_to :client
  belongs_to :product

end
