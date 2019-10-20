class Payment < ApplicationRecord
  belongs_to :user
  belongs_to :invoice
  belongs_to :payplan
end
