module Insint
  # This class is responsible for applying discounts to insales order by api
  class Discount
    def initialize(saved_subdomain, datas)
      @user = User.find_by_subdomain(saved_subdomain)
      @saved_subdomain = saved_subdomain
      @datas = datas
      @discounts = nil
      @error = []
    end

    def apply_discount
      get_discount_rules
      discount_amount = calculate_discount
      if @error.count.positive?
        [false, @error.join(' ')]
      else
        [true, discount_amount]
      end
    end

    private

    def get_discount_rules
      Apartment::Tenant.switch(@saved_subdomain) do
        @discounts = Discount.all
      end
    end

    def calculate_discount
      Apartment::Tenant.switch(@saved_subdomain) do
      end
    end
  end
end