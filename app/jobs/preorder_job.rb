class PreorderJob < ApplicationJob
    queue_as :preorder_job

    def perform(mycase_id, operation, insint)

        preorder = Preorder.new(mycase_id, operation, insint)
        preorder.do_action

    end


end

# test
# preorder = Preorder.new(110,"preorder_order",User.find(407).insints.first)
# preorder.do_action
