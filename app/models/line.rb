class Line < ApplicationRecord
    belongs_to :mycase
    belongs_to :product
    belongs_to :variant

    before_save :normalize_data_white_space


    def normalize_data_white_space
        self.attributes.each do |key, value|
        self[key] = value.squish if value.respond_to?("squish")
        end
    end

end
