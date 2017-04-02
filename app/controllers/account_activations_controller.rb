require 'uri'

class AccountActivationsController < ApplicationController
  def edit
    user = UserFinder.find_by_email!(params[:type], params[:email])

    if user.activation_token_valid?(params[:id])
      user.activate!

      render 'success'
    else
      render 'failure'
    end
  rescue ActiveRecord::ActiveRecordError => e
    render 'failure'
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
      # # flash[:info] = "Error sending email confirmation"
      # # render "signup_failure"
      # # return
    # # end
    # redirect_to "/"
  # end

end
