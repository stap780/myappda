class Payment < ApplicationRecord
  belongs_to :user
  belongs_to :invoice
  belongs_to :payplan

  after_create :change_status_test_period

  private

  def change_status_test_period
    if user.status_test_period
      user.update(status_test_period: false)
    end
  end
end
