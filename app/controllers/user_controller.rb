class UserController < ApplicationController
  respond_to :json
  before_filter :sso_redirect
  skip_before_filter :require_user, only: [:new, :create]

  def new
    @user = User.new
#    @user.validate_email = true
    @security_questions = security_questions 
    # add a default option for new accounts
    @security_questions << {"id"=>0, "name"=>"Select One"}
    @details = {'user'=> {'question_id' => 0}}
    render layout: 'authenticate'
  end

  def update_password
    @error = password_check #@error will fall through to js
    if @error.blank?
       @jiffy_api = VST::External::Jiffy.new(access_token: current_user.access_token, guid: current_user.guid)
       Rails.logger.info "\n[>PWC<] ip: #{request.remote_ip} email: #{current_user.email}  at: #{Time.now()} ref: #{session[:http_referer]}\n"
       @jiffy_api.update_user(params.require(:user).permit([:password, :password_confirmation, :current_password])) rescue nil
       @error = "Unexpected error, try again later" if @jiffy_api.nil? || !@jiffy_api.success?
    end
  end

  def update_security
    @error = Security.new(current_user).update(params)
  end

  def update_notifications
    @jiffy_api = VST::External::Jiffy.new(access_token: current_user.access_token, guid: current_user.guid)
    @jiffy_api.update_user(params.require(:user).permit([:promote_option, :survey_option]))
    respond_to do |wants|
      wants.json {   
        if @jiffy_api.success?
          render text: t('messages.notification_success'), status: 200
        else
          render text: t('messages.notification_failure'), status: :unprocessable_entity
        end
      }
    end
  end

  def update_bookshelf_preference
    @jiffy_api = VST::External::Jiffy.new(access_token: current_user.access_token, guid: current_user.guid)
    @jiffy_api.update_user(params.require(:user).permit([:bookshelf_preference]))
    @error = "Unexpected error, try again later" if !@jiffy_api.success?
  end

  def edit
    @details = get_user_details
    @security_questions = security_questions
  
    if @user.school_state.nil? 
      @institutions = ['Select State']
    else
      @institutions = institution_list(@user.school_state)
    end
    xml = @details.to_xml(:root => 'user')
  end

  def update
    current_user.hit_api = true
    # we test for errors in the js but I would like to move it all here with the rewrite
    if current_user.update_attributes(params.require(:user).permit(*User.mass_assign_attributes))
      #I18n.locale = current_user[:locale]
      I18n.locale = "en"
      session[:locale] = current_user[:locale]
      #Rails.logger.debug "\n\n\n good \n\n\n"
    else
      #Rails.logger.debug "\n\n\n bad #{current_user.errors.to_yaml}\n\n\n"
    end
  end

  private
    def password_check
      error =''    
      pass = params['user']['password']
      if pass != params['user']['password_confirmation']
        error = t('user.password.password_mismatch')
      end
    
      if pass.length < 4
        error = t('user.password.password_min')
      end

      # check that the current password is correct
      user = User.authenticate(current_user.email, params[:user][:current_password]) rescue false
      if !user
       error = t('user.password.wrong_current')
      end
      error
    end  

    def get_user_details
      user_api = VST::External::Jiffy.new(:user_guid => current_user.guid)
      user_data = user_api.user_details_from_guid(true)
      @details = Hash.from_xml(user_data[1])
    end

    def security_questions
      api_results = VST::External::P2Services::QuestionService.new()
      resp = api_results.security_questions()
      questions_hash = Hash.from_xml(resp[1])
      list = questions_hash["questions"]
      completed = []
      list.each {|q|
        entry = {'id' => q['id'], 'name' => t("user.security.security-question#{q['id']}")}
        completed << entry
      }
      return completed
    end

    def institution_list(selected_state)
      count = Institution.count
      # maybe update when older than 3 days, not sure
      update_institutions unless count > 0
      @ins =  Institution.where("state = ?",  selected_state)
      list = []
      @ins.each {|x| list << x.name}
      list.sort
    end

    def update_institutions
      Institution.delete_all
      api = VST::External::Jiffy.new(:access_token => current_user.access_token)
      api.institutions
      xml = Nokogiri::XML(api.response_body)
      list = []
      xml.css("institution").each do |i|
        id = i.css("id").text
        name = i.css("name").text
        address = i.css("mailing-address").text
        city = i.css("mailing-city").text
        state = i.css("mailing-state").text
        zip = i.css("mailing-zipcode").text
        i = Institution.new
        i.id = id
        i.name = name
        i.address = address
        i.city = city
        i.state = state
        i.zip = zip
        i.save
      end
  end

  # def create
  #    @user = User.new(params.require(:user).permit([:email, :last_name, :first_name, :locale, :promote_option, :survey_option]))
  #    @user.hit_api = true
  #    #@user.validate_email = true
  #   if @user.save
  #     respond_to do |wants|
  #       wants.json { render json: @user, status: :created }
  #       wants.html { render json: @user, status: :created }
  #     end
  #   else
  #     respond_to do |wants|
  #      wants.json { render json: @user.errors, status: :unprocessable_entity }
  #      wants.html { render json: @user.errors, status: :unprocessable_entity }
  #     end
  #   end
  # end

  #def valid_password(pass)
   # pass.length <=12 && pass =~ /^.*(?=.{8,})(?=.*\d)(?=.*[a-z])(?=.*[A-Z])(?=.*[@#$%^&+=]).*$/
  #end

  # def exists? # for create user step1 see if user exists

  #   if user = User.find_by_email(params[:email])
  #     response = true
  #   else
  #     api = VST::External::Jiffy.new(guid: params[:email])
  #     api.user_details_from_guid
  #     response = api.success?
  #   end

  #   respond_to do |wants|
  #     wants.json { render json: {exists: response} }
  #   end
  # end
end