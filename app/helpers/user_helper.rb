module UserHelper
  def email_locked? 
    @details['user']['email_locked'].to_s.downcase == 'true'
  end
end
