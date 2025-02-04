# BulkDeleteJob < ApplicationJob
class BulkDeleteJob < ApplicationJob
  queue_as :bulk_delete
  sidekiq_options retry: 0

  def perform(collection_ids, options = {})
    model = options[:model]
    items = model.camelize.constantize.where(id: collection_ids)

    result, message = Bulk::Delete.call(items, {model: model})
    # if result
    #   BulkDeleteNotifier.with(
    #     # record: items.first,
    #     message: "Success",
    #     error: nil,
    #     model: model
    #   ).deliver(User.find_by_id(options[:current_user_id]))
    # else
    #   BulkDeleteNotifier.with(
    #     # record: items.first,
    #     message: message,
    #     error: true,
    #     model: model
    #   ).deliver(User.find_by_id(options[:current_user_id]))
    #   Turbo::StreamsChannel.broadcast_update_to(
    #     User.find(options[:current_user_id]),
    #     "bulk_actions",
    #     target: "modal",
    #     template: "shared/show_modal",
    #     layout: false,
    #     locals: {message: message}
    #   )
    # end

  end
end
