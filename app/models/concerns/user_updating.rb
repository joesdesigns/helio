module UserUpdating
  extend ActiveSupport::Concern

 included do
    # API only
    @API_accessors = []

    # both API & local
    @API_attributes= @API_accessors + [:first_name, :last_name, :email]

    @mass_assign_attributes = @API_attributes + [:locale]

    # local only
    @local_attributes = [:locale]

    class << self
      attr_reader :API_accessors, :API_attributes, :mass_assign_attributes, :local_attributes
    end

    # these be for user creation on this side of the aisle
    attr_accessor *@API_accessors

    # need to be able to set and verify the password locally
    # attr_accessor :password_confirmation

    attr_accessor :hit_api, :jiffy_api
    attr_accessor :needs_license_update, :require_book_list_update
    
    # attributes that can be set from the API, but can't be updated
    # attr_accessor :max_desktop_activations, :max_mobile_activations, :require_book_list_update,
    #               :require_deactivate

    # we only want the reader so the writer doesn't overwrite the method defined below
    attr_reader :last_activation_date

    #before_create :create_user_via_api
    before_update :update_user_via_api
  end

protected

  def attributes_for_API
    attrs = {}
    self.class.API_attributes.each { |a| attrs[a] = changes[a][1] unless !changes.has_key?(a)} 
    return attrs
  end

  def add_errors_from_response!(nokogiri)
    errors.clear
    nokogiri.css('error-response').each do |err|
      errors.add(:base, err.css('>error-text').text.strip)
    end

    nokogiri.css('error').each do |error|
      errors.add(error.css('>field').text.strip.underscore, error.css('>message').text.strip)
    end
  end

  def update_attributes_from_response!(nokogiri)
    nokogiri.css('user>*').each do |node|
      attr = node.name.underscore.to_sym
      send("#{attr}=", node.text.strip) if respond_to?("#{attr}=")
    end
  end

  # def create_user_via_api
  #   if hit_api
  #     @jiffy_api = VST::External::Jiffy.new
  #     @jiffy_api.create_user(attributes_for_API)
  #     add_errors_from_response!(@jiffy_api.response_body.nokogiri)
  #     return false unless errors.blank?
  #     return false unless @jiffy_api.success?

  #     update_attributes_from_response!(@jiffy_api.response_body.nokogiri)
  #  end
  # end

   def update_user_via_api
   if hit_api
      attrs = attributes_for_API
      # no need to call if nothing the API cares about changed
      return true if attrs.blank?
      @jiffy_api = VST::External::Jiffy.new(access_token: access_token, guid: guid)
      @jiffy_api.update_user(attrs)

      add_errors_from_response!(@jiffy_api.response_body.nokogiri)
      return false unless errors.blank?
      return false unless @jiffy_api.success?

      update_attributes_from_response!(@jiffy_api.response_body.nokogiri)
    end
  end
end