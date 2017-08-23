class ForgotController < ApplicationController

  skip_before_filter :require_user
  skip_before_filter :setup_branding
  def index
   render layout: 'authenticate'
  end

  def create
    #put options ie domain in environment specific files
      # options= {:domain => 'myaccount.vitalsource.com', :brand_name => 'Account Center', :update_url => 'http://myaccount.vitalsource.com/forgot/reset'}
      # options[:email] = params[:user][:email] 
      # forgot = VST::External::P2Services::ForgotService.new(options)
      # resp = forgot.send_reset
      # #.success? doesn't work so check the code
      # if resp[:error_code].to_i == 200
      #     @message = {:header => 'Email Sent', :text => 'An email has been sent with instructions to reset your password.'}
      # else
      #   if resp[:error_code].to_i == 478
      #     @message = {:header => 'Account Doesn’t Exist', :text => 'Please try again or create a Vitalsource account.'}
      #   else
      #     @message = {:header => 'Something went wrong', :text => 'Please try again.'}
      #   end
      # end
  end

  def update
   # if params[:new_password] && params[:new_password].length > 7 && params[:token]
   #    upd = VST::External::P2Services::ForgotService.new()
   #    resp = upd.update_password(params[:new_password],params[:token])

   #    if !upd.success?
   #       @message = {:header => 'Failure', :text => 'An unexpected error has occured.'}
   #    else
   #      # this API returns an error code of 200, even thought it is not an error 
   #      if resp[:error_code].to_i != 200
   #         @message = {:header => 'Failure', :text => 'An error has occured.'}
   #      else
   #         @message = {:header => 'Success', :text => 'Password has been reset.'}
   #      end
   #    end
   #  else
   #    @message = {:header => 'Invalid', :text => 'Password must be at least 8 characters long."'}
   #  end
  end

  def reset
    render layout: 'authenticate'
  end

end
