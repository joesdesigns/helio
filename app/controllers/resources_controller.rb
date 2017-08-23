class ResourcesController < ApplicationController
 
  def index
    @show_pod = current_user.licenses.where('lsi_id is not null').count > 0
    # only hit the api if there is a reason
    @pod_url = pod_url unless !@show_pod
    Rails.logger.debug "\n\n\n session:needs_license_update #{session[:needs_license_update]}"
    resources = Resources.new(current_user)
    if session[:needs_license_update] == true
      Rails.logger.debug "\n\n\n ---- updating license ---\n\n\n"
      resources.update_license
      session[:needs_license_update] == false
    end
    @licenses = resources.licenses 
  end

  def show
    @license = current_user.licenses.references(:book).includes(:book).where(['books.isbn = ?', params[:id]]).first
  end

  def redeem_eresource
    api = VST::External::P2Services::UserService.new()
    api.redeem_eresource(current_user.email,params[:vbid])
    if api.success?
      response_hash = Hash.from_xml(api.parsed_response.to_s)
      code = response_hash['access_code']
    else
      # we may want to do this on the javascript side, decide later
      code = "Error: With a message"
    end

    respond_to do |wants|
      wants.any{ render :json => {:code => code, :success => api.success?} }
    end
  end

  private

  def pod_url
    res = VST::External::BusinessCenter.new(:user_guid => current_user.guid,:access_token => current_user.access_token).pod()
    result = res[1].split('"')
    return result[3]
  end
end
