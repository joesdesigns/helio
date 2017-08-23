module TransactionsHelper
  def edition_copyright(edition, copyright)
    details = []
    if edition.to_i > 0
      details << "#{edition.to_i.ordinalize} Edition"
    end

    if !copyright.blank?
      details << "&copy; #{copyright}"
    end
    resp = details.join(', ')
    resp = "#{resp}." unless resp.blank?
  end

  def currency_symbol(code)
    dollahs = Currency.new(code)
    dollahs.symbol
  end

  def tax_label(code)
    dollahs = Currency.new(code)
    dollahs.tax_label
  end

  def tax_postfix(code)
    dollahs = Currency.new(code)
    dollahs.tax_postfix  
  end

  def active_tab(name)
    params[:action] == name ? 'selected ' : ''
  end
end