class Restock < ApplicationRecord

  belongs_to :variant
  belongs_to :client
  before_save :set_status_if_new_record

  Status = ["Ждём поступления","Отправляется","Сообщение отправлено"]

  def self.check_quantity_and_change_status
    restocks = Restock.where(status: "Ждём поступления")
      restocks.each do |restock|
        variant = restock.variant
        variant.get_ins_data
        restock.update!(status: "Отправляется") if variant.quantity > 0
      end
  end


  private

  def set_status_if_new_record
      self.status = "Ждём поступления" if new_record?
  end

end
