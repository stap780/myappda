# This module provides functionality for bulk deleting records in a application.
module BulkDelete
  extend ActiveSupport::Concern

  def bulk_delete
    # puts "########### search_params download => #{search_params}"
    if delete_type == 'selected' && !params[items].present?
      flash.now[:error] = 'Выберите позиции'
    else
      ## this is was for test - CreateXlsxJob.perform_later(collection_ids, {model: "Product",current_user_id: current_user.id} )
      # puts "delete_collection_ids => #{delete_collection_ids}"
      BulkDeleteJob.perform_now(delete_collection_ids, {model: model.to_s, current_user_id: current_user.id})
      flash.now[:success] = 'Запустили удаление'
    end
    render turbo_stream: [
      render_turbo_flash
    ]
  end

  private

  def items
    "#{controller_name.singularize}_ids".to_sym
  end

  def model
    controller_name.singularize.camelize.constantize
  end

  def model_product?
    model == 'Product'
  end

  def delete_type
    params[:delete_type]
  end

  def delete_collection_ids
    puts "delete_collection_ids search_params => #{search_params}"
    if delete_type == 'selected'
      collection_ids = model.include_images.where(id: params[items]).pluck(:id) if model_product?
      collection_ids = model.where(id: params[items]).pluck(:id) unless model_product?
    end
    if delete_type == 'filtered' && search_params.present?
      collection_ids = model.include_images.ransack(search_params).result(distinct: true).pluck(:id) if model_product?
      collection_ids = model.all.ransack(search_params).result(distinct: true).pluck(:id) unless model_product?
    end
    if delete_type == 'all'
      collection_ids = model.include_images.pluck(:id) if model_product?
      collection_ids = model.all.pluck(:id) unless model_product?
    end
    collection_ids
  end
end
