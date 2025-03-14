# CreateZipXlsxJob
class CreateZipXlsxJob < ApplicationJob
  queue_as :print
  sidekiq_options retry: 0

  def perform(collection_ids, options = {})
    model = options[:model]
    Apartment::Tenant.switch(options[:tenant]) do
      items = model.camelize.constantize.where(id: collection_ids)

      success, zipped_blob = ZipXlsx.call(items, {model: model, tenant: options[:tenant]})
      puts "zipped_blob => #{zipped_blob}"
      if success

        Turbo::StreamsChannel.broadcast_replace_to(
          [options[:tenant], :bulk_actions],
          target: 'modal',
          template: 'shared/success_bulk',
          layout: false,
          locals: {blob: zipped_blob, message: nil}
        )
      else

        Turbo::StreamsChannel.broadcast_replace_to(
          [options[:tenant], :bulk_actions],
          target: 'modal',
          template: 'shared/error_bulk',
          layout: false,
          locals: {error_message: zipped_blob, error_process: 'CreateZipXlsxJob'}
        )
      end
    end
  end
end
