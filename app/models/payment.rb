class Payment < ApplicationRecord
  belongs_to :user
  belongs_to :invoice
  belongs_to :payplan

  #validates :subdomain, presence: true #не понял зачем это

  before_create :add_subdomain #не понял зачем это

  private

  def add_subdomain
    self.subdomain = user.subdomain
  end
end
