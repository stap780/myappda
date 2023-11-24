class RestockJob < ApplicationJob
    queue_as :restock_job
    
    ###### WE HAVE TASK THAT WORK EVERY 1 HOUR and not use job

    # def perform(insales_order_id, operation, insint)
    #     service = ApiInsales.new(insint)
    #     order = service.order(insales_order_id)
    # order_status = "declined"
    # service.set_order_status(insales_order_id, order_status) if order.financial_status == "pending"
    # end


  end