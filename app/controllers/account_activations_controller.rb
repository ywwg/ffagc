class AccountActivationsController < ApplicationController
  def edit
    type = params[:type]
    # brainded pluralization 
    @types = "#{type}s"
    
    if type == "artist"
      user = Artist.find_by(email: params[:email])
    elsif type == "voter"
      user = Voter.find_by(email: params[:email])
    elsif type == "admin"
      user = Admin.find_by(email: params[:email])
    end
    
    logger.debug "here's the user! #{user.inspect}"
    
    # hmmmm.... can't check logged in...
    if user.activated 
      
    end
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
      logger.debug "nope"
      # flash[:danger] = "Invalid activation link"
      #redirect_to root_url
      render "failure"
    end
  end
  
end
