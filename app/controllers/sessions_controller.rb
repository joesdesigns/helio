class SessionsController < ApplicationController
  skip_before_filter :require_user
  skip_before_filter :setup_branding
  
  def new
    #create a blank user instance
    @user = User.new
    render layout: 'authenticate'
  end

  def create
    # authenticate against connect/local db return user if valid
    @user = User.authenticate(params[:user][:email], params[:user][:password])
    if verify_recaptcha(model: @user) && @user
      # session[:needs_license_update] = @user.needs_license_update
      signin!(@user)
     # signin!(@user, @user.needs_license_update)
      redirect_to_return_or_back_or_default
    else
      flash.now[:error] = I18n.t('flash.login_fail')
      render :action => :new, layout: 'authenticate'
     end
  end

  def destroy
    signout!
    redirect_to login_path and return
  end

protected

  def redirect_to_return_or_back_or_default
    params[:return].blank? ? redirect_back_or_default : redirect_to(params[:return])
  end
end
