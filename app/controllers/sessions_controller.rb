class SessionsController < ApplicationController
  def create_artist
    if(!params[:session][:email].present? || !params[:session][:password].present?)
      render "login_failure"
      return
    end
    
    artist = Artist.find_by_email(params[:session][:email])
    if artist && !artist.activated 
      redirect_to controller: "account_activations", action: "unactivated", 
          type: "artists", email: params[:session][:email]
      return
    end
    
    if artist && artist.authenticate(params[:session][:password])
      session[:artist_id] = artist.id
      redirect_to :controller => "artists", :action => "index"
    else
      render "login_failure"
    end
  end

  def delete_artist
    session[:artist_id] = ""
    redirect_to :controller => "artists", :action => "index"
  end

  def create_voter
    if(!params[:session][:email].present? || !params[:session][:password].present?)
      render "login_failure"
    return
    end

    voter = Voter.find_by_email(params[:session][:email])
    if voter && !voter.activated 
      redirect_to controller: "account_activations", action: "unactivated", 
          type: "voters", email: params[:session][:email]
      return
    end
    
    if voter && voter.authenticate(params[:session][:password])
      session[:voter_id] = voter.id
      redirect_to :controller => "voters", :action => "index"
    else
      render "login_failure"
    end
  end

  def delete_voter
    session[:voter_id] = ""
    redirect_to :controller => "voters", :action => "index"
  end

  def create_admin
    if(!params[:session][:email].present? || !params[:session][:password].present?)
      render "login_failure"
    return
    end

    admin = Admin.find_by_email(params[:session][:email])
    # Although admins are auto-activated, one could unactivate an admin account
    # to prevent future logins (doesn't protect against admins with persisting
    # session cookies.)
    if admin && !admin.activated 
      redirect_to controller: "account_activations", action: "unactivated",
          type: "admins", email: params[:session][:email]
      return
    end
    
    if admin && admin.authenticate(params[:session][:password])
      session[:admin_id] = admin.id
      redirect_to :controller => "admins", :action => "index"
    else
      render "login_failure"
    end
  end

  def delete_admin
    session[:admin_id] = ""
    redirect_to :controller => "admins", :action => "index"
  end

end
