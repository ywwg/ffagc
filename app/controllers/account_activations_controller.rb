require 'uri'

class AccountActivationsController < ApplicationController
  def edit
    @type = params[:type]
    email = URI.unescape(params[:email]).downcase
    if @type == "artists"
      user = Artist.find_by(email: email)
    elsif @type == "voters"
      user = Voter.find_by(email: email)
    elsif @type == "admins"
      user = Admin.find_by(email: email)
    end

    if user && !user.activated? && ApplicationController.activate_succeed?(user, params[:id])
      user.update_attribute(:activated, true)
      user.update_attribute(:activated_at, Time.zone.now)
      if user.save
        render "success"
      else
        render "failure"
      end
    else
      if user && user.activated?
        render "success"
      else
        render "failure"
      end
    end
  end
  
  def unactivated
    @type = params[:type]
    @email = params[:email]
  end
  
  # This doesn't work because we have to regenerate the token *and* the
  # digest, and then resend to the user.  Therefore it'd have to happen in
  # the individual user type controllers.  I can't be bothered, so let's just
  # leave this undone for now.
  
  # def resend_activation
    # @type = params[:type]
    # @email = params[:email]
#     
    # if @type == "artists"
      # @user = Artist.find_by(email: params[:email].downcase)
    # elsif @type == "voters"
      # @user = Voter.find_by(email: params[:email].downcase)
    # elsif @type == "admins"
      # @user = Admin.find_by(email: params[:email].downcase)
    # end
#     
    # if @user.activated
      # redirect_to :controller => "home", :action => "index"
    # end
#     
    # # Send email!
    # #begin
      # # Will need to be replaced with deliver_now
      # UserMailer.account_activation(@type, @user).deliver!
    # # rescue
      # # flash[:notice] = "Error sending email confirmation"
      # # render "signup_failure"
      # # return
    # # end
    # redirect_to "/"
  # end
  
end
