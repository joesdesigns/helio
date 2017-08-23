class OrderPresenter

  def initialize(order)
    @order = order
  end

  def order_date
    @order['order_date'].to_date.strftime('%-m/%-d/%Y')
  end  

  def tally
    @order.count
  end

  def number
    @order['number']
  end

  def sub_total 
    total = 0.0
    @order['purchase_items'].each{|line_item| total += line_item['item_price'].to_f} 
    return total
  end
  
  def currency
    @order["currency"]
  end
  
  def items
    @order['purchase_items']
  end
  
  def tax(with_total=false)
    total = 0.0
    @order['purchase_items'].each do |line_item|
      if with_total
       total += (line_item['tax'].to_f + line_item['item_price'].to_f)  
      else
        total += line_item['tax'].to_f 
      end
    end
    return total
  end

  def credit_card_type
    @order["credit_card_type"].upcase
  end

  def credit_card_number
    @order["credit_card_number"]
  end

end

