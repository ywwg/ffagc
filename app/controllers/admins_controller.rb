class AdminsController < ApplicationController
  load_and_authorize_resource only: [:index, :new, :create]

  before_filter :init_admin
  before_filter :init_artists
  before_filter :init_voters
  before_filter :verify_admin, except: [:index, :new, :create]

  def index
  end

  def new
  end

  def create
    @admin = Admin.new(admin_params)

    if @admin.save
      # Only assign the session to the new account if it's the first one.
      unless session[:admin_id].present?
        session[:admin_id] = @admin.id
        redirect_to root_path
        return
      end

      flash[:success] = "New admin <#{@admin.email}> created."

      # reset @admin so form is empty
      @admin = Admin.new
    end

    render 'new'
  end

  def verify
    voter = Voter.find(params[:id])
    voter.verified = params[:verify]
    if voter.save
      send_email = params[:send_email] == "true"
      if send_email
        begin
          UserMailer.voter_verified(voter, event_year).deliver_now
          logger.info "email: voter verification sent to #{voter.email}"
        rescue
          flash[:warning] = "Error sending email"
          redirect_to action: "voters"
          return
        end
        flash[:info] = "Voter notified by email"
      end
    end

    redirect_to action: "voters"
  end

  def send_fund_emails
    submissions = GrantSubmission.where(id: params[:ids].split(','))
    sent = 0
    submissions.each do |gs|
      if params[:send_email] == "true"
        artist = Artist.where(id: gs.artist_id).take
        grant = Grant.where(id: gs.grant_id).take
        begin
          if gs.granted_funding_dollars == 0
            UserMailer.grant_not_funded(gs, artist, grant, event_year).deliver
            logger.info "email: grant not funded sent to #{artist.email}"
          else
            UserMailer.grant_funded(gs, artist, grant, event_year).deliver
            logger.info "email: grant funded sent to #{artist.email}"
          end
        rescue
          flash[:warning] = "Error sending email (#{sent} sent)"
          redirect_to action: "index"
          return
        end
        sent += 1
      end
      gs.funding_decision = true
      gs.save
    end

    flash[:info] = "#{sent} Funding Emails Sent"
    redirect_to action: "index"
  end

  def send_question_emails
    submissions = GrantSubmission.where(grant_id: active_vote_grants)
    sent = 0
    submissions.each do |gs|
      if gs.questions != nil && !gs.questions.empty?
        artist = Artist.where(id: gs.artist_id).take
        grant = Grant.where(id: gs.grant_id).take
        begin
          UserMailer.notify_questions(gs, artist, grant, event_year).deliver
          logger.info "email: questions notification sent to #{artist.email}"
        rescue
          flash[:warning] = "Error sending emails (#{sent} sent)"
          redirect_to action: "index"
          return
        end
        sent += 1
      end
    end

    flash[:info] = "#{sent} Question Notification Emails Sent"
    redirect_to action: "index"
  end

  def clear_assignments
    if admin_logged_in?
      VoterSubmissionAssignment.destroy_all
    end
    redirect_to action: "index"
  end

  # distributes voter assignments fairly and can handle newly-added voters and
  # submissions without blowing up existing assignments.
  #
  # First cleans out the assignments from invalid entries.
  #
  # Goes through all grants and for each one gets a list of voters who are
  # verified and are available to vote on that grant.  Then goes through each
  # submission for that grant.  If the submission has fewer assignments than
  # max_voters_per_submission (or the number of voters), we find the voter with
  # the fewest total assignments and give the submission to them.
  def assign
    clean_assignments
    max_voters_per_submission = 3
    # NOTE: TEMP HACK: Keep a list of seen grant submission titles, and if we
    # see a duplicate, skip it.  This way artists that submitted at more than
    # one grant level won't appear twice in the voting assignments.  This
    # should be removed once we have proper tier selection.
    seen = Set.new
    Grant.all.each do |g|
      voters = Voter.joins(:grants_voters)
          .where('grants_voters.grant_id' => g.id, 'voters.verified' => true)
          .all
      GrantSubmission.where(grant_id: g.id).each do |gs|
        # Only skip if the name *and* artist id are the same, in case two
        # artists picked the same name.
        gs_uid = [gs.name, gs.artist_id]
        if seen.include?(gs_uid)
          next
        end
        seen.add(gs_uid)
        while assigned_count(gs.id) < [max_voters_per_submission, voters.count].min
          vsa = VoterSubmissionAssignment.new
          vsa.voter_id = fewest_assigned_voter(voters, gs.id).id
          vsa.grant_submission_id = gs.id
          vsa.save
        end
      end
    end

    redirect_to action: "index"
  end

  # Goes through the voter assignments, and deletes entries if the
  # grant no longer exists or the voter no longer exists.  Unverified voters
  # keep their assignments because their values are ignored, so they can be
  # readded (which happens).
  def clean_assignments
    VoterSubmissionAssignment.all.each do |vsa|
      if Voter.find_by_id(vsa.voter_id) == nil
        vsa.destroy
        next
      end
      if GrantSubmission.find_by_id(vsa.grant_submission_id) == nil
        vsa.destroy
      end
    end
  end

  def init_artists
    @artists = Artist.all
  end

  def init_voters
    @voters = Voter.all
    @verified_voters = Voter.where(verified: true)
    # builds a run-time array to map assignments to voters for easy display
    @verified_voters.each do |vv|
      vv.class_eval do
        attr_accessor :assigned
      end

      vv.assigned = Array.new
      VoterSubmissionAssignment.where("voter_id = ?",vv.id).each do |vsa|
        gs = GrantSubmission.find_by_id(vsa.grant_submission_id)
        if gs != nil
          vv.assigned.push("#{gs.name}(#{gs.id})")
        end
      end
    end
  end

  def artists
  end

  def artist_info
    id = params.require(:id)
    @artist = Artist.find(id)
    @artist_survey = ArtistSurvey.where(artist_id: id).take
  end

  def voters
  end

  def voter_info
    id = params.require(:id)
    @voter = Voter.find(id)
    @voter_survey = VoterSurvey.where(voter_id: id).take
    @grants = Grant.all
  end

  def submissions
    @scope = params[:scope] || 'active'
    @order = params[:order] || 'name'
    @revealed = params[:reveal] == 'true'
    @show_scores = params[:scores] == 'true'

    if @scope == 'active'
      @grant_submissions = GrantSubmission.where(grant_id: active_vote_grants)
    else
      @grant_submissions = GrantSubmission.all
    end

    @results = VoteResult.results(@grant_submissions)

    if @order == 'score'
      @grant_submissions = @grant_submissions.to_a.sort_by { |gs| [gs.grant_id, -gs.avg_score] }
    elsif @order == 'name'
      @grant_submissions = @grant_submissions.to_a.sort_by { |gs| gs.name }
    end
  end

  private

  def admin_params
    params.require(:admin).permit(:name, :email, :password, :password_confirmation)
  end

  # counts the number of voters a submission is assigned to
  def assigned_count(submission_id)
    VoterSubmissionAssignment.where(grant_submission_id: submission_id).count
  end

  # given a list of voters, returns the voter with the fewest assignments.
  def fewest_assigned_voter(voters, submission_id)
    fewest = nil
    low_count = -1
    # Randomize order to spread submissions around.
    voters.shuffle.each do |v|
      # skip if this voter has already been assigned this submission
      if VoterSubmissionAssignment.exists?(voter_id: v.id, grant_submission_id: submission_id)
        # Could return nil if all voters have already been assigned
        # this submission, but that shouldn't happen because of the max count
        # check in the caller.
        next
      end
      count = VoterSubmissionAssignment.where(voter_id: v.id).count
      if low_count < 0 || count < low_count
        fewest = v
        low_count = count
      end
    end
    return fewest
  end

  def verify_admin
    unless can? :manage, :all
      redirect_to '/'
      return
    end
  end

  def init_admin
    @admin = Admin.new
  end
end
