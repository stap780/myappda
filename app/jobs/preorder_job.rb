# frozen_string_literal: true

# job for send preorder message
class PreorderJob < ApplicationJob
    queue_as :preorder_job

    def perform(mycase_id, operation, insint)

        preorder = PreorderService.new(mycase_id, operation, insint)
        preorder.do_action

    end


end

# test
# preorder = PreorderService.new(110,"preorder_order",User.find(407).insints.first)
# preorder.do_action
