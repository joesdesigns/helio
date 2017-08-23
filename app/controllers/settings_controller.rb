class SettingsController < ApplicationController
  respond_to :json

  def index
    @devices = get_device_list
    @owner = get_owner['user']
    @details = get_user_details
  end

  def deactivate
    device_api = VST::External::Jiffy.new(:user_guid => current_user.guid)
    device_api.deactivate_device(params[:deactivation_id])
    body = { success: device_api.success? }
      respond_to do |wants|
      wants.any { render json: body, status: device_api.response_code }
    end
    # we need to rebuild the list, or at least hide the one deleted
  end

  private

  def get_owner
   # Rails.logger.info("the user's guid: #{current_user.guid}")
    user_data = VST::External::Jiffy.new(:user_guid => current_user.guid).user_details_from_guid(true)
    Hash.from_xml(user_data[1])
  end

  def get_user_details
      user_api = VST::External::Jiffy.new(:user_guid => current_user.guid)
      user_data = user_api.user_details_from_guid(true)
      details = Hash.from_xml(user_data[1])
  end



  def get_device_list
    @device_api = VST::External::Jiffy.new(:user_guid => @user.guid)
    @device_api.devices
    @doc = @device_api.response_body.parse
    devices = []
    @doc.find('//device').each do |d|
      next unless d['active'] == 'true'
      device_hash = {:name => d['name'], :id => d['id'], :created_on => Time.parse(d['created-on']), :version => d['client-version'], :mobile => d['mobile']}
      device_hash[:last_license_update] = Time.parse(d['last-license-update']) unless d['last-license-update'].blank?
      devices << device_hash
    end
    return devices
  end
end
