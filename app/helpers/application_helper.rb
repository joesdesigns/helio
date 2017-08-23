module ApplicationHelper
  def present(object, klass = nil)
    klass ||= "#{object.class}Presenter".constantize
    presenter = klass.new(object, self, @branded_config)
    yield presenter if block_given?
    presenter
  end

  def active_name(option)
    return option == controller_name ? 'current' : 'notcurrent'
  end

  def localize_price(price,currency) 
    @currency = Currency.new(currency)
    if currency == 'GBP'
      "#{number_to_currency(price, unit: @currency.symbol)}"
    else
      "#{number_to_currency(price, unit: @currency.symbol)} #{@currency.postfix}"
    end
  end

  def localize_item_price(item,currency) 
    @currency = Currency.new(currency)
    if currency == 'GBP'
      "#{number_to_currency(item['item_price'].to_f + item['tax'].to_f, unit: @currency.symbol)}"
    else
      "#{number_to_currency(item['item_price'], unit: @currency.symbol)} #{@currency.postfix}"
    end
  end


  def us_states
    # https://github.com/vitalsource/validates_as_postal_code
    # There are gems for this but since it is on tempoary lets use an array
    # until a spec is defined.
    [
      ['', ''],
      ['Alabama', 'AL'],
      ['Alaska', 'AK'],
      ['Arizona', 'AZ'],
      ['Arkansas', 'AR'],
      ['California', 'CA'],
      ['Colorado', 'CO'],
      ['Connecticut', 'CT'],
      ['Delaware', 'DE'],
      ['District of Columbia', 'DC'],
      ['Florida', 'FL'],
      ['Georgia', 'GA'],
      ['Hawaii', 'HI'],
      ['Idaho', 'ID'],
      ['Illinois', 'IL'],
      ['Indiana', 'IN'],
      ['Iowa', 'IA'],
      ['Kansas', 'KS'],
      ['Kentucky', 'KY'],
      ['Louisiana', 'LA'],
      ['Maine', 'ME'],
      ['Maryland', 'MD'],
      ['Massachusetts', 'MA'],
      ['Michigan', 'MI'],
      ['Minnesota', 'MN'],
      ['Mississippi', 'MS'],
      ['Missouri', 'MO'],
      ['Montana', 'MT'],
      ['Nebraska', 'NE'],
      ['Nevada', 'NV'],
      ['New Hampshire', 'NH'],
      ['New Jersey', 'NJ'],
      ['New Mexico', 'NM'],
      ['New York', 'NY'],
      ['North Carolina', 'NC'],
      ['North Dakota', 'ND'],
      ['Ohio', 'OH'],
      ['Oklahoma', 'OK'],
      ['Oregon', 'OR'],
      ['Pennsylvania', 'PA'],
      ['Puerto Rico', 'PR'],
      ['Rhode Island', 'RI'],
      ['South Carolina', 'SC'],
      ['South Dakota', 'SD'],
      ['Tennessee', 'TN'],
      ['Texas', 'TX'],
      ['Utah', 'UT'],
      ['Vermont', 'VT'],
      ['Virginia', 'VA'],
      ['Washington', 'WA'],
      ['West Virginia', 'WV'],
      ['Wisconsin', 'WI'],
      ['Wyoming', 'WY']
    ]
  end
end
