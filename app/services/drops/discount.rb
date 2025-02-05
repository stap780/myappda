class Drops::Discount < Liquid::Drop

  def initialize(discount)
    @discount = discount
  end

  def items
    @discount['order_lines']
  end

end