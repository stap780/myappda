class PreorderJob < ApplicationJob
    queue_as :preorder_job

    def perform(mycase, operation, insint)

        preorder = Services::Preorder.new(mycase, operation, insint)
        preorder.do_action

    end


end