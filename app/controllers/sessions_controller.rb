class SessionsController < ApplicationController
  def create_artist
    if(!params[:session][:email].present? || !params[:session][:password].present?)
      render "login_failure"
      return
    end

    artist = Artist.find_by_email(params[:session][:email].downcase)
    if !artist
      render "login_failure"
      return
    end

    if !artist.activated
      redirect_to controller: "account_activations", action: "unactivated",
          type: "artists", email: params[:session][:email]
      return
    end

    if !artist.authenticate(params[:session][:password])
      render "login_failure"
      return
    end

    session[:artist_id] = artist.id
    redirect_to :controller => "artists", :action => "index"
  end

  def delete_artist
    session[:artist_id] = ""
    redirect_to :controller => "artists", :action => "index"
  end

  def voter_login
    if voter_logged_in?
      redirect_to voters_path
    end
  end

  def create_voter
    if(!params[:session][:email].present? || !params[:session][:password].present?)
      render "login_failure"
      return
    end

    voter = Voter.find_by_email(params[:session][:email].downcase)
    if !voter
      render "login_failure"
      return
    end

    if !voter.activated
      redirect_to controller: "account_activations", action: "unactivated",
          type: "voters", email: params[:session][:email]
      return
    end

    if !voter.authenticate(params[:session][:password])
      render "login_failure"
      return
    end

    session[:voter_id] = voter.id
    redirect_to :controller => "voters", :action => "index"
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

    admin = Admin.find_by_email(params[:session][:email].downcase)
    if !admin
      render "login_failure"
      return
    end
    # Although admins are auto-activated, one could unactivate an admin account
    # to prevent future logins (doesn't protect against admins with persisting
    # session cookies.)
    if !admin.activated
      redirect_to controller: "account_activations", action: "unactivated",
          type: "admins", email: params[:session][:email]
      return
    end

    if !admin.authenticate(params[:session][:password])
      render "login_failure"
      return
    end

    session[:admin_id] = admin.id
    redirect_to :controller => "admins", :action => "index"
  end

  def delete_admin
    session[:admin_id] = ""
    redirect_to :controller => "admins", :action => "index"
  end

end
