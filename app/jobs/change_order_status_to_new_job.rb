class ChangeOrderStatusToNewJob < ApplicationJob
  queue_as :order_job

  def perform(insales_order_id, operation, insint)
    service = ApiInsales.new(insint)
    order = service.order(insales_order_id)
    order_status = "new"
    service.set_order_status(insales_order_id, order_status)
  end

end