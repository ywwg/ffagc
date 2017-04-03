# including a view helper in a controller -- a sign of things to come :/.
include ActionView::Helpers::TextHelper

class ApplicationController < ActionController::Base
  # Prevent CSRF attacks by raising an exception.
  # For APIs, you may want to use :null_session instead.
  protect_from_forgery with: :exception

  rescue_from CanCan::AccessDenied, :with => :deny_access
  rescue_from ActiveRecord::RecordNotFound, :with => :deny_access

  def event_year
    Rails.configuration.event_year
  end
  helper_method :event_year

  def timezone_string
    ActiveSupport::TimeZone[Rails.configuration.event_timezone].formatted_offset
  end

  private

  def active_vote_grants
    Grant.voting_active(DateTime.current, timezone_string)
  end

  def active_submit_grants
    now = DateTime.current
    deadline_leniency_time = now - 1.hours
    Grant.submission_active(now, deadline_leniency_time, timezone_string)
  end

  def any_submit_open?
    active_submit_grants.exists?
  end
  helper_method :any_submit_open?

  def any_vote_open?
    return active_vote_grants.exists?
  end
  helper_method :any_vote_open?

  def active_vote_names
    active_vote_grants.select(&:name).map(&:name)
  end
  helper_method :active_vote_names

  def active_submit_names
    active_submit_grants.select(&:name).map(&:name)
  end
  helper_method :active_submit_names

  # returns a Hash where the key is a pair of meeting dates and the value is
  # another hash, containing an index number, a list of grant ids of grants
  # being discussed on those dates that are NOT hidden, and a list of names.
  def collated_meetings
    meetings = Hash.new
    collated_id = 0
    Grant.where(hidden: false).order(meeting_one: :asc).each do |g|
      key = [g.meeting_one, g.meeting_two]
      if !meetings.has_key?(key)
        meetings[key] = {'id' => collated_id, 'grant_ids' => Array.new, 'names' => Array.new}
        collated_id += 1
      end
      meetings[key]['grant_ids'].push(g.id)
      meetings[key]['names'].push(g.name)
    end

    return meetings
  end
  helper_method :collated_meetings

  def discussion_status(grant_id)
    discuss = []
    g = GrantSubmission.find(grant_id)
    if g.questions != nil && !g.questions.empty?
      discuss.push("Q")
    end
    if g.answers != nil && !g.answers.empty?
      discuss.push("A")
    end
    status = discuss.join('&').squeeze(' ')
    if status == ""
      status = "None"
    end
    supplement_count = Proposal.where(:grant_submission_id => g.id).count
    status += ", #{pluralize(supplement_count, 'doc')}"
    return status
  end
  helper_method :discussion_status

  def active_grant_funding_total(finalized)
    total = 0
    GrantSubmission.where(grant_id: active_vote_grants, funding_decision: finalized).each do |gs|
      if gs.granted_funding_dollars != nil
        total += gs.granted_funding_dollars
      end
    end
    return total
  end
  helper_method :active_grant_funding_total

  def all_grant_funding_total(finalized)
    total = 0
    GrantSubmission.where(funding_decision: finalized).each do |gs|
      if gs.granted_funding_dollars != nil
        total += gs.granted_funding_dollars
      end
    end
    return total
  end
  helper_method :all_grant_funding_total

  def grant_max_funding_dollars_json
    Grant.all.select(:id, :max_funding_dollars).to_json
  end
  helper_method :grant_max_funding_dollars_json

  # /artists, /voters, /admins
  public
  # This method is expected by CanCan
  def current_user
    current_admin || current_artist || current_voter
  end
  helper_method :current_user

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

  def verified_voter_logged_in?
    true if current_voter && current_voter.verified
  end
  helper_method :verified_voter_logged_in?

  def participating_checked(voter_id, grant_id)
    if GrantsVoter.exists?(voter_id: voter_id, grant_id: grant_id)
      return "checked"
    end
    return nil
  end
  helper_method :participating_checked

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

  public
  # Password token generation helpers
  def self.new_token
    SecureRandom.urlsafe_base64
  end

  def self.digest(secret)
    return BCrypt::Password.create(secret)
  end

  def self.activate_succeed?(user, token)
    BCrypt::Password.new(user.activation_digest).is_password?(token)
  end

  protected

  def deny_access
    flash[:danger] = "503 Forbidden"
    render 'errors/503', status: :forbidden
  end
end
