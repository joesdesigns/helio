class Resources
  def initialize(current_user)
    @user = current_user
  end

  def licenses
    @licenses = @user.licenses.includes(:book).reject{|l| l.ancillaries.empty? }
  end

  def update_license
    Rails.logger.debug "\n\n\n *** updating license for you ***\n\n\n"
    @user.licenses.delete_all
    @user.add_licenses
    @user.updated_license_at = Time.now
    @user.save
  end  
end
