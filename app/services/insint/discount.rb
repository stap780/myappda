# This class is responsible for applying discounts to insales order by api
class Insint::Discount < ApplicationService

  def initialize(saved_subdomain, datas)
    @user = User.find_by_subdomain(saved_subdomain)
    @saved_subdomain = saved_subdomain
    @datas = datas
    @error = []
  end

  def call
    add_collection_title_to_datas
    data = get_discount
    if @error.count.positive?
      [false, @error.join(' ')]
    else
      [true, data]
    end
  end

  private

  def get_discount
    Apartment::Tenant.switch(@saved_subdomain) do
      data = {}
      Discount.order(position: :asc).each do |discount|
        if @datas['order_lines'].count == 2 && discount.rule == '2_items'
          data['discount'] = discount.shift
          data['discount_type'] = discount.points.upcase
          data['title'] = discount.notice
        elsif @datas['order_lines'].count == 3 && discount.rule == '3_items'
          data['discount'] = discount.shift
          data['discount_type'] = discount.points.upcase
          data['title'] = discount.notice
        else
          check_liquid_discount_rule(discount.rule)
        end
      end
      data
    end
  end

  def add_collection_title_to_datas
    user = User.find_by_subdomain(@saved_subdomain)
    service = ApiInsales.new(user.insints.first)

    return @error << 'integration not work' unless service.work?

    @datas['order_lines'].each do |line|
      product = service.get_product_data(line['product_id'])
      cols_titlies = product.collections_ids.map{|id| InsalesApi::Collection.find(id).title }
      line['collections_titlies'] = cols_titlies
    end
  end

  def check_liquid_discount_rule
    template = Liquid::Template.parse(discount.rule)
    html_as_string = template.render({'discount' => Drops::Discount.new(@datas)}, { strict_variables: true })
    if html_as_string.include?('true')
      data['discount'] = discount.shift
      data['discount_type'] = discount.points.upcase
      data['title'] = discount.notice
    end
  end

end
