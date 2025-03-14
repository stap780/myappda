# frozen_string_literal: true

# ZipXlsx < ApplicationService
class ZipXlsx < ApplicationService
  require 'caxlsx'

  def initialize(collection, options = {})
    @collection = collection
    @model = options[:model]
    @template = "#{@model.downcase.pluralize}/index"
    @file_name = "#{options[:tenant]}_#{@model.downcase}.xlsx"
    @zip_file_name = "#{options[:tenant]}_#{@model.downcase}.zip" #"#{@template.tr('/', '_')}.zip"
    @error_message = 'We have error whith zip create'
  end

  def call
    # renderer = ActionController::Base.new
    # xlsx = renderer.render_to_string(layout: false, handlers: [:axlsx], formats: [:xlsx], template: @template, locals: {collection: @collection})
    # File.binwrite("#{Rails.public_path}/#{@file_name}", xlsx)

    compressed_filestream = output_stream
    compressed_filestream.rewind
    # compressed_filestream
    blob = ActiveStorage::Blob.create_and_upload!(io: compressed_filestream, filename: @zip_file_name)
    if blob
      [true, blob]
    else
      [false, @error_message]
    end
  end

  private

  def output_stream
    renderer = ActionController::Base.new

    Zip::OutputStream.write_buffer do |zos|
      zos.put_next_entry(@file_name)
      zos.print renderer.render_to_string(
        layout: false, handlers: [:axlsx], formats: [:xlsx], template: @template, locals: {collection: @collection}
      )
    end
  end
end
