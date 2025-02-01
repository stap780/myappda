# This class is responsible for applying discounts to insales order by api
class Insint::Discount < ApplicationService

  def initialize(saved_subdomain, datas)
    @user = User.find_by_subdomain(saved_subdomain)
    @saved_subdomain = saved_subdomain
    @datas = datas
    @error = []
  end

  def apply_discount
    data = calculate_discount
    if @error.count.positive?
      [false, @error.join(' ')]
    else
      [true, data]
    end
  end

  private

  def calculate_discount
    Apartment::Tenant.switch(@saved_subdomain) do
      data = {
        'discount': nil,
        'discount_type': nil,
        'title': nil
      }
      Discount.order(position: :asc).each do |discount|
        if @datas['order_lines'].count == 2 && discount.rule == '2_items'
          data['discount'] = discount.shift
          data['discount_type'] = discount.points.upcase
          data['title'] = discount.notice
        end
        if @datas['order_lines'].count == 3 && discount.rule == '3_items'
          data['discount'] = discount.shift
          data['discount_type'] = discount.points.upcase
          data['title'] = discount.notice
        end
      end
      data
    end
  end

end
