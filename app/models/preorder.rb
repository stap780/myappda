class Preorder < ApplicationRecord
    belongs_to :product
    belongs_to :variant
    belongs_to :client
    before_save :set_status_if_new_record
    validates_uniqueness_of :variant_id, :scope => :client_id

    Status = [["Ждём поступления","wait"],["Появился","ready"],["Сообщение отправлено","send"]]

    scope :for_inform, -> { where(status: "ready") }
    scope :status_wait, -> { where(status: "wait") }

    def self.find_dups
        columns_that_make_record_distinct = [:client_id, :variant_id]
        distinct_ids = Preorder.select("MIN(id) as id").group(columns_that_make_record_distinct).map(&:id)
    end

    private

    def set_status_if_new_record
        self.status = "wait" if new_record?
    end

end
#<Preoder id: 4, variant_id: 2, client_id: 28, created_at: "2022-06-12 12:52:08", updated_at: "2022-06-12 12:52:08", status: "Ждём поступления", product_id: nil>