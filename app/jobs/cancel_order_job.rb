class CancelOrderJob < ApplicationJob
  queue_as :order_job

  def perform(insales_order_id, operation, insint)
    service = Services::InsalesApi.new(insint)
    order = service.order(insales_order_id)
    service.set_cancel_status(insales_order_id) if order.financial_status == "pending"
  end


end