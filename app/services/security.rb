class Security
  def initialize(current_user)
    @api  = VST::External::Jiffy.new(:access_token => current_user.access_token, :user_guid => current_user.guid)
  end

  def update(params)
    if params['user']['question_response'].blank? || params['user']['question_id'].blank?
      return I18n.t('user.security.security-response-min')
    end  
    @api.update_user(params.require(:user).permit([:question_id, :question_response]))
    return @api.success? ? [] : I18n.t('messages.failure')
  end

end