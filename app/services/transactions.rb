class Transactions

  def initialize(current_user)
    @api  = VST::External::Jiffy.new(:access_token => current_user.access_token, :user_guid => current_user.guid)
    @api.purchase_history
    response = @api.success? ? @api.parsed_response : []
    @orders = response.map {|order| OrderPresenter.new(order)}
  end

  def active_orders
    active = []
    @orders.each do |ord|
      active << ord if ord.sub_total > 0
    end
    return active
  end

  def refunded_items
    refunded = []
    @orders.each do |order| # each order
      order.items.each do |item|
        if item["refunded"]
          item['order_date']= order.order_date
          item['number']= order.number
          item['currency']= order.currency
          refunded <<  item
        end
      end
    end
    return refunded
  end

  def order_details(orderid)
    details = @orders.find {|o| o.number == orderid}
    # @orders.map do |order|
    #   OrderPresenter.new(order)

    #   presenter.items.each do |item|
    #     # item ==> ItemPresenter
    #     <%= item.total #%>
    #     <%= item.tax #%>
    #   end
    # end
  end

  def item_details(sku)
    @item_detail = []
    @orders.each do |order|
      order.items.each do |item|
        if item['sku'] == sku
          @item_detail = item 
          @item_detail['number'] = order.number
          @item_detail['order_date'] = order.order_date
          @item_detail['credit_card_type'] = order.credit_card_type
          @item_detail['credit_card_number'] = order.credit_card_number
          @item_detail['currency'] = order.currency
          break 
        end
      end
    end
    return @item_detail
  end

  def refunded_skus
      refunded = []
      @orders.each do |order|
        order.items.each do |item|
          if item["refunded"]
            refunded << item["sku"] unless refunded.include?(item["sku"])
          end
        end
      end
      return refunded
  end
end
