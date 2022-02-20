class Payplan < ApplicationRecord
  has_many :payments
  has_many :invoices

end
