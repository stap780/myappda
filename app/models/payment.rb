class Payment < ApplicationRecord
  belongs_to :user
  belongs_to :invoice
  belongs_to :payplan

  validates :subdomain, presence: true

  before_save :add_subdomain

  private

  def add_subdomain
    self.subdomain = user.subdomain
  end
end
