class Currency
  def initialize(currency_code)
    case currency_code
      when 'GBP'
        @locale_code = :en_GB
      when 'AUD'
        @locale_code = :en_AU  
      else
        @locale_code = :en
    end
  end

  def symbol
     I18n.t('number.currency.format.unit', :locale => @locale_code)
  end

  def locale
    @locale_code
  end

  def postfix
    I18n.t('number.currency.format.postfix', :locale => @locale_code)
  end

  def tax_label
    I18n.t('number.currency.format.tax_label', :locale => @locale_code)
  end

  def tax_postfix
    I18n.t('number.currency.format.tax_postfix', :locale => @locale_code)
  end

end
