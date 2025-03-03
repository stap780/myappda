class Dashboard < ApplicationRecord
  SEARCHABLE_MODEL_ATTRIBUTES = {
    'Mycase' => %w[number client_phone client_email client_name],
    'Client' => %w[name surname email phone],
    'Product' => %w[title]
  }

  def self.search(params_query)
    @search_results = {}
    if params_query.present?
      SEARCHABLE_MODEL_ATTRIBUTES.each do |model_name, searchable_fields|
        model_results = model_name.constantize.ransack("#{searchable_fields.join('_or_')}_matches_all": "%#{params_query}%").result.uniq

        fields_for_search_result = ['id'] + searchable_fields
        fields_for_search_result = %w[id number] if model_name == 'Mycase'

        convert_model_results = []
        model_results.each do |item|
          value = fields_for_search_result.map { |attr| item.send(attr)}
          convert_model_results.push(value)
        end
        @search_results[model_name] = convert_model_results
      end
    else
      @search_results['Empty'] = ['no results']
    end
    @search_results

    # @search_results data example - {
    #  "Mycase"=>[],
    #  "Client"=>[
    #   [1, 'abandoned_4ZJTTz6mVd*Omfw8', nil, 'test44@mail.ru', '+7(901)111-44-55'],
    #   [4, 'test', nil, 'panaet80@gmail.com', '+79011111111']
    #  ],
    #  "Product"=>[]
    # }

  end
end