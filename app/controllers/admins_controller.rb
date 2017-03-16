class AdminsController < ApplicationController

  before_filter :init_admin
  before_filter :init_artists
  before_filter :init_voters
  before_filter :verify_admin_logged_in, except: [:create, :index, :signup]

  def verify_admin_logged_in
    if !current_admin
      redirect_to "/"
      return
    end
  end

  def init_admin
      @admin = Admin.new
  end

  def signup

  end

  def admin_params
    params.require(:admin).permit(:name, :password_digest, :password, :password_confirmation, :email)
  end

  def create
    # if there is no admin, go ahead and create the account (initial config)
    # even if no admin is logged in.
    if admin_exists? && !current_admin
      redirect_to "/"
      return
    end

    if Admin.exists?(email: admin_params[:email].downcase)
      flash[:warning] = "The email address #{admin_params[:email.downcase]} already exists in our system"
      render "signup_failure"
      return
    end

    @admin = Admin.new(admin_params)
    @admin.email = @admin.email.downcase
    # Auto-activate admins
    @admin.activated = true

    if @admin.save
      # Only assign the session to the new account if it's the first one.
      if !session[:admin_id]
        session[:admin_id] = @admin.id
      end
      render "signup_success"
    else
      render "signup_failure"
    end
  end

  def reveal
    init_submissions
  end

  def verify
    voter = Voter.find(params[:id])
    voter.verified = params[:verify]
    if voter.save
      send_email = params[:send_email] == "true"
      if send_email
        # Will need to be replaced with deliver_now
        begin
          UserMailer.voter_verified(voter, event_year).deliver
          logger.info "email: voter verification sent to #{voter.email}"
        rescue
          flash[:warning] = "Error sending email"
          redirect_to action: "voters"
          return
        end
        flash[:notice] = "Voter notified by email"
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

    flash[:notice] = "#{sent} Funding Emails Sent"
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

    flash[:notice] = "#{sent} Question Notification Emails Sent"
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
  # Goes through all grants and for each one gets a list of voters who are
  # verified and are available to vote on that grant.  Then goes through each
  # submission for that grant.  If the submission has fewer assignments than
  # max_voters_per_submission (or the number of voters), we find the voter with
  # the fewest total assignments and give the submission to them.
  def assign
    max_voters_per_submission = 3
    Grant.all.each do |g|
      voters = Voter.joins(:grants_voters)
          .where('grants_voters.grant_id' => g.id, 'voters.verified' => true)
          .all
      GrantSubmission.where(grant_id: g.id).each do |gs|
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

  def init_submissions
    @results = Hash.new
    active_submissions = GrantSubmission.where(grant_id: active_vote_grants)
    @grant_submissions = GrantSubmission.all.order(grant_id: :asc)
    @grant_submissions.each do |gs|
      votes = Vote.where("grant_submission_id = ?", gs.id)

      t_sum = 0
      t_num = 0;
      c_sum = 0;
      c_num = 0;
      f_sum = 0;
      f_num = 0;

      votes.each do |gsv|
        if gsv.score_t
          t_sum = t_sum+gsv.score_t
          t_num = t_num+1
        end

        if gsv.score_c
          c_sum = c_sum+gsv.score_c
          c_num = c_num+1
        end

        if gsv.score_f
          f_sum = f_sum+gsv.score_f
          f_num = f_num+1
        end

      end

      @results[gs.id] = Hash.new

      @results[gs.id]['num_t'] = t_num
      @results[gs.id]['sum_t'] = t_sum

      if t_num > 0
        @results[gs.id]['avg_t'] = t_sum.fdiv(t_num).round(2)
      end

      @results[gs.id]['num_c'] = c_num
      @results[gs.id]['sum_c'] = c_sum

      if c_num > 0
        @results[gs.id]['avg_c'] = c_sum.fdiv(c_num).round(2)
      end

      @results[gs.id]['num_f'] = f_num
      @results[gs.id]['sum_f'] = f_sum

      if f_num > 0
        @results[gs.id]['avg_f'] = f_sum.fdiv(f_num).round(2)
      end

      if @results[gs.id]['avg_t'] && @results[gs.id]['avg_c'] && @results[gs.id]['avg_f']
        @results[gs.id]['avg_s'] = ((@results[gs.id]['avg_t'] + @results[gs.id]['avg_c'] + @results[gs.id]['avg_f'])/3.0).round(2)
      end

      @results[gs.id]['num_total'] = t_num + c_num + f_num
    end

    active_submissions.each do |gs|
      gs.class_eval do
        attr_accessor :avg_score
      end
      gs.avg_score = @results[gs.id]['avg_s']
      if gs.avg_score == nil
        gs.avg_score = 0
      end
    end
    @sorted_submissions = active_submissions.sort_by{|gs| gs.avg_score}
        .reverse
        .sort_by{|gs| gs.grant_id}
  end

  def index
    init_submissions
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

  def grants
    if !current_admin
      redirect_to "/"
      return
    end
    @grants = Grant.all
  end

  def submissions
    init_submissions
  end

  private

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
end
