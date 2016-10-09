class AccountActivationsController < ApplicationController
  def edit
    @type = params[:type]
    
    if @type == "artists"
      user = Artist.find_by(email: params[:email].downcase)
    elsif @type == "voters"
      user = Voter.find_by(email: params[:email].downcase)
    elsif @type == "admins"
      user = Admin.find_by(email: params[:email].downcase)
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
      if user.activated? 
        render "success"
      else
        render "failure"
      end
    end
  end
  
end
