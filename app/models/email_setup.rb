class EmailSetup < ApplicationRecord

    def self.ransackable_attributes(auth_object = nil)
        EmailSetup.attribute_names
    end


    
    
end
