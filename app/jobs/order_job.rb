class OrderJob < ApplicationJob #delete after 20 of July 2023
    queue_as :order_job
  
    def perform(insales_order_id, operation, insint)
      service = Services::InsalesApi.new(insint)
      order = service.order(insales_order_id)
      service.set_cancel_status(insales_order_id) if order.financial_status == "pending"
    end
  
  
  end