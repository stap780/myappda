class Payplan < ApplicationRecord
  has_many :payments
  has_many :invoices
  has_many :favorite_setups
  validates :handle, presence: true


  Services = ["extra","favorite", "restock"]
  Period = ["1", "3", "6","12","no limit"]

  def self.favorite_free_id
     Payplan.where(service_handle: "favorite", price: 0 ).first.id
  end

  def self.restock_free_id
     Payplan.where(service_handle: "restock", price: 0 ).first.id 
  end


end
