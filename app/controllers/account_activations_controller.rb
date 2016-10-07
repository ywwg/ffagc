class AccountActivationsController < ApplicationController
  def edit
    @type = params[:type]
    
    if @type == "artists"
      user = Artist.find_by(email: params[:email])
    elsif @type == "voters"
      user = Voter.find_by(email: params[:email])
    elsif @type == "admins"
      user = Admin.find_by(email: params[:email])
    end
    
    logger.debug "here's the user! #{user.inspect}"
    
    if user && !user.activated? && ApplicationController.activate_succeed?(user, params[:id])
      user.update_attribute(:activated,    true)
      user.update_attribute(:activated_at, Time.zone.now)
      if user.save
        render "success"
      else
        render "failure"
      end
      # flash[:success] = "Account activated!"
      #redirect_to user
      
      # show a success thing
    else
      # XXX: This can happen if user is already logged in
      logger.debug "nope"
      # flash[:danger] = "Invalid activation link"
      #redirect_to root_url
      render "failure"
    end
  end
  
end
