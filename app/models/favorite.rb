class Favorite < ApplicationRecord

  belongs_to :client
  belongs_to :product

end
