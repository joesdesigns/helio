class User < ActiveRecord::Base
  include UserUpdating
  validates_presence_of :first_name, :last_name
  validates :email, presence: true, uniqueness: true
 
  has_many :licenses, :dependent => :delete_all
  has_many :ancillaries, :through => :licenses
  has_many :books,:through => :licenses

  def self.authenticate(email, password)
    result = VST::External::P2Services::UserService.new.authenticate(email, password)
    return false if result.blank?
    user = User.find_or_create_by_guid(result[:guid])
  end

  def self.find_or_create_by_guid(guid)
    #exit if no guid
    return nil if guid.blank?
    #lookup the user in nocal db
    user = User.find_by_guid(guid)
    #if we find it then update it and return the updated version
    user = User.new(needs_license_update: true) unless user
    # this user exists in the local db, update it

    api = VST::External::Jiffy.new(:user_guid => guid)
    api.user_details_from_guid(true)
    user_data = api.parsed_response
    last_activation_date = user_data.find('//last-activation-date').first.content rescue nil
    require_book_list_update = user_data.find('//require-book-list-update').first.content rescue nil
     new_activation = Time.parse(last_activation_date).utc > user.updated_license_at rescue true
     if (new_activation == true || require_book_list_update == true) && last_activation_date
       user.needs_license_update = true
       Rails.logger.debug "\n\n ** a license update is required ****\n\n"
    else
       user.needs_license_update = false
       Rails.logger.debug "\n\n ** no license update necessary ****\n\n"
     end 
    user.first_name = user_data.find('//first-name').first.content rescue nil
    user.last_name = user_data.find('//last-name').first.content rescue nil
    user.email = user_data.find('//email').first.content rescue nil
    user.email_locked = user_data.find('//email-locked').first.content rescue nil
    user.last_brand_accessed = user_data.find('//last-brand-accessed').first.content rescue nil
    Rails.logger.info "\n\n\n last brand: #{user.last_brand_accessed}"
    user.sso_only = user_data.find('//sso_only').first.content rescue nil
    user.guid = guid
    user.save

    # we could do this anywhere but why not here and now??  
    # if user.needs_license_update
    #   Rails.logger.debug "\n\n\n *** updating license should be performed ***\n\n\n"
    #  end
    
    return user
  end
  
  def setup_access_token!(overwrite=false)
    if read_attribute(:access_token).blank? || overwrite
      jiffy = VST::External::Jiffy.new(:user_guid => self.guid)
      jiffy.get_access_token
      self.update_attribute(:access_token, jiffy.access_token)
    end
    return read_attribute(:access_token)
  end

  def add_licenses(opts={})
    doc = VST::External::P2Services::UserService.license(email, opts) rescue nil
    Rails.logger.warn("Bad license response for email: #{email}") and return unless doc
    
    expirations = parse_expirations(doc)

    doc.find('//assets/asset').each do |node|
      #ignore expired licenses
      expiration_id = node.find_first('expiration')['id'] rescue nil
      next unless  expirations[expiration_id] >= Time.now.utc   

      asset_id  = node['id']
      url = node.find_first('url').content rescue nil
      next unless url
      next unless url =~ /^vbk/
      isbn = url.split(':')[1]
      lsi_id = node.find_first('lsi_id').content rescue nil
      book_attrs = {
        :asset_id         => asset_id,
        :isbn         => isbn,
        :title        => (node.find_first('title').content rescue ''),
        :author       => (node.find_first('author/author_name').content rescue ''),
        :kind_id      => (node.find_first('kind')['id'] rescue nil)

      }

      license_attrs = {
         :expires_on   => (expirations[expiration_id] rescue nil),
         :lsi_id       => lsi_id
      }

      # if this book doesn't exist then create it, otherwise update it
      book = Book.find_by_isbn(book_attrs[:isbn]) 

      if book
        book.update_attributes(book_attrs)  
      else  
        book = Book.create(book_attrs)
      end
      book.save!
      # see if this book is current associated with a license
      # if it is update the license otherwise create a license
      license = licenses.find_by_book_id(book.id)
      if license
        license.update_attributes(license_attrs)
      else
        license = licenses.create(license_attrs.merge(book_id: book.id)) 
      end
      license.save
      # rebuild the ancillaries for this license
      license.ancillaries.delete_all
      node.find('ancillary').each do |a|
        ancil = license.ancillaries.build({
          ancillary_type: a['type'],
          platform:       a['platform'],
          size:           a['size'],
          title:          a['title'],
          href:           a['href'],
          access_code:    a['code'],
          revealed:       (a['revealed'] == 'true')
        })
        ancil.save
      end
    end
    return 
  end

  def access_token
    at = read_attribute(:access_token)
    at.blank? ? setup_access_token! : at
  end

  def sso_only?
    # we need to make sure that this gets set on users that are already in the db
    sso = read_attribute(:sso_only)
    return sso unless sso.nil?

    if read_attribute(:sso_only).nil?
      api = VST::External::P2Services::UserService.new(guid: guid)
      results = api.details
      self.sso_only = results[:sso_only]
      # results.each do |key, val|
      #   if self.respond_to?("#{key}=")
      #     self.send("#{key}=", val)
      #   end
      # end
      self.save
    end

    return read_attribute(:sso_only)
  end
 
  private
 
  def parse_expirations(doc)
    expirations = {}
    doc.find('expirations/expiration').each do |expiration_node|
      expires_id = expiration_node['id']
      expires_date = expiration_node.find_first('expiration_date').content
      expirations[expires_id] = DateTime.parse(expires_date)
    end
    expirations
  end

  alias_method :sso_only, :sso_only?
end
