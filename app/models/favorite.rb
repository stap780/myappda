class Favorite < ApplicationRecord
  # default_scope { order(created_at: :desc) }
  belongs_to :client
  belongs_to :product

end
