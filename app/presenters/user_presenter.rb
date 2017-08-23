class UserPresenter
  def initialize(user, template, branded_config)
    @user = user
    @template = template
    @branded_config = branded_config
  end

  def h
    @template
  end

  def email_label
    if @branded_config[:custom][:uop_email_locked]
      uop_custom_email_label
    else
      @user.email_locked ? locked_email_label : unlocked_email_label
    end 
  end

  def email_field
    if @branded_config[:custom][:uop_email_locked]
      uop_custom_email_field
    else
      @user.email_locked ? locked_email_field : unlocked_email_field
    end
  end

  private

  def locked_email_label
    h.label_tag '', I18n.t('user.personal.email_locked') 
  end

  def locked_email_field
    h.label_tag '', @user.email , class: 'textfields bold', "aria-required" => true 
  end

  def unlocked_email_label
    h.label_tag '[user][email]', I18n.t('user.personal.email')  
  end

  def unlocked_email_field
    h.text_field_tag "[user][email]", @user.email , class: 'textfields', "aria-required" => true 
  end

  def uop_custom_email_label
    h.label_tag '', I18n.t('branded.uop.email_label').to_s.html_safe , class: 'uop_email_label'
  end
  
  def uop_custom_email_field
    h.label_tag '', @user.email , class: 'textfields ', "aria-required" => true
  end
end
