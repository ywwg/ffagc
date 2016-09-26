class ApplicationController < ActionController::Base
  # Prevent CSRF attacks by raising an exception.
  # For APIs, you may want to use :null_session instead.
  protect_from_forgery with: :exception

  before_filter :artist_logged_in?, :voter_logged_in? #what does this do?
  
  private
  # Returns a list of the ids of grants which are currently active for submitting.
  def active_submit_grants
    now = DateTime.current
    return Grant.where("submit_start <= ?", now).where("submit_end >= ?", now).select(:id)
  end
  helper_method :active_submit_grants
  
  # Returns a list of the ids of grants which are currently active for voting.
  def active_vote_grants
    now = DateTime.current
    return Grant.where("vote_start <= ?", now).where("vote_end >= ?", now).select(:id)
  end 
  
  public
  def any_submit_open?
    return active_submit_grants.count > 0
  end
  helper_method :any_submit_open?
  
  def any_vote_open?
    return active_vote_grants.count > 0
  end
  helper_method :any_vote_open?
  
  def active_vote_names
    now = DateTime.current
    return Grant.where("vote_start <= ?", now).where("vote_end >= ?", now).select(:name)
  end
  helper_method :active_vote_names
  
  
  # /artists, /voters, /admins

  # /artists

  public #why
  def current_artist
    @current_artist ||= Artist.find_by_id(session[:artist_id]) if session[:artist_id]
  end
  helper_method :current_artist

  private
  def artist_logged_in?
    true if current_artist
  end
  helper_method :artist_logged_in?
  
  def artist_has_submission?
    if current_artist
      return true if GrantSubmission.where(artist_id: session[:artist_id]) != []
    end
    return false
  end
  helper_method :artist_has_submission?

  # /voters

  public
  def current_voter
    @current_voter ||= Voter.find_by_id(session[:voter_id]) if session[:voter_id]
  end

  helper_method :current_voter

  private
  def voter_logged_in?
    true if current_voter
  end

  helper_method :voter_logged_in?

  # /admins

  public
  def current_admin
    @current_admin ||= Admin.find_by_id(session[:admin_id]) if session[:admin_id]
  end

  helper_method :current_admin

  private
  def admin_logged_in?
    true if current_admin
  end
  
  helper_method :admin_logged_in?

  def admin_exists?
    true if Admin.exists?
  end
  helper_method :admin_exists?
end
