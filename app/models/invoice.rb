class Invoice < ApplicationRecord

  belongs_to :payplan

  has_many :payments, :dependent => :destroy

end
