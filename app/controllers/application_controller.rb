class ApplicationController < ActionController::Base
  protect_from_forgery :with => :null_session
  before_filter :accept_doorman_session
  before_filter :require_user
  before_filter :setup_config
  before_filter :set_localization

  helper_method :current_user, :design_branding

  def design_branding
   @branded_design ||= (BRANDED_DESIGN[request.host] || BRANDED_DESIGN[:default])
  end

  def sso_redirect
    redirect_to devices_url if current_user.sso_only?
  end

  def set_localization
    #I18n.locale = session[:locale]
    # Temp fix until connect supports locale
    #I18n.locale = 'en'
    I18n.locale = @branded_config[:locale] rescue 'en'
  end

  def require_user
    return true if signed_in?
    not_authorized!
  end

  def setup_config
    if signed_in? 
      if current_user.sso_only?
        @branded_config = BRANDED_CONFIG[:sso]
      else
        @branded_config = last_branded_config 
      end
    else
       @branded_config = BRANDED_CONFIG[:default]
    end
    Rails.logger.debug "\n\n\n config is now #{@branded_config.to_yaml}"
  end

  def signed_in?
    return true if current_user   
  end

  def current_user
    @user ||= User.find_by_id(session[:user_id])
  end

  def not_authorized!()
    store_location!        #remember where they wanted to be so we can return there after login
    redirect_to login_url  #sessions#new
  end

  def store_location!
    session[:return_to] = request.fullpath
  end

  def signin!(user)
    session[:user_id] = user.id
    session[:locale] = user.locale.nil? ? 'en' : user.locale
    session[:needs_license_update] = user.needs_license_update
    session[:http_referer] = request.env["HTTP_REFERER"]
    return user
  end

  def redirect_back_or_default(default=nil)
    default = default.blank? ? root_url : default
    redirect_to(session[:return_to] || default)
    session[:return_to] = nil
  end

  def signout!
    session.clear
    @user = nil
  end

private

  def last_branded_config
    lb = current_user.last_brand_accessed.downcase.to_sym rescue nil
    if BRANDED_CONFIG[lb].nil? 
      return BRANDED_CONFIG[:default]
    else
      return BRANDED_CONFIG[lb]
    end
  end 

  def last_brand_set?
    !current_user.last_brand_accessed.nil? && !current_user.last_brand_accessed.blank? 
  end
end
