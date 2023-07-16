class CancelOrderJob < ApplicationJob
  queue_as :order_job

  def perform(insales_order_id, operation, insint)
    service = Services::InsalesApi.new(insint)
    order = service.order(insales_order_id)
    order_status = "declined"
    service.set_order_status(insales_order_id, order_status) if order.financial_status == "pending"
  end


end