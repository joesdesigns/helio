class InstitutionsController < ApplicationController
  respond_to :json

  def index
    # list = []
    # @ins ||= Institution.where("state = ?",  params[:selected_state])
    # @ins.each {|i| list << i.name}

    # render :json => list.sort, :status =>'200'
    # @api  = VST::External::Jiffy.new(:access_token => current_user.access_token, :user_guid => current_user.guid)
    # @api.purchase_history
    # @purchases = JSON.parse @api.response_body
  end
end