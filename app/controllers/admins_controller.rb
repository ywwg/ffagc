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
      flash[:notice] = "The email address #{admin_params[:email.downcase]} already exists in our system"
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
        UserMailer.voter_verified(voter, event_year).deliver!
      end
    end

    redirect_to action: "voters"
  end

  def send_fund_emails
    submissions = GrantSubmission.where(id: params[:ids].split(','))
    submissions.each do |gs|
      if params[:send_email] == "true"
        artist = Artist.where(id: gs.artist_id).take
        grant = Grant.where(id: gs.grant_id).take
        if gs.granted_funding_dollars == 0
          UserMailer.grant_not_funded(gs, artist, grant, event_year).deliver!
        else
          UserMailer.grant_funded(gs, artist, grant, event_year).deliver!
        end
      end
      gs.funding_decision = true
      gs.save
    end

    redirect_to action: "index"
  end

  def send_question_emails
    submissions = GrantSubmission.where(grant_id: active_vote_grants)
    submissions.each do |gs|
      if gs.questions != nil && !gs.questions.empty? > 0
        artist = Artist.where(id: gs.artist_id).take
        grant = Grant.where(id: gs.grant_id).take
        UserMailer.notify_questions(gs, artist, grant, event_year).deliver!
      end
    end

    redirect_to action: "index"
  end

  def assign
    # a terrible terrible thing :(

    #delete current assignments
    VoterSubmissionAssignment.destroy_all

    #undercooked copypasta w/ no sauce
    @verified_voters = Voter.where(verified: true)
    vv_arr = @verified_voters.to_ary
    idx = 0
    max = vv_arr.size
    per = 3

    @sv = Hash.new

    @submissions = []
    if max == 0
      # bail if no verified voters??
      logger.warn "WARNING: no verified voters"
      redirect_to action: "index"
      return
    end

    @submissions = GrantSubmission.where(grant_id: active_vote_grants).order(grant_id: :asc)

    @submissions.each do |s|
      @sv[s.id] = Hash.new

      @sv[s.id]['id'] = s.id
      @sv[s.id]['name'] = s.name
      @sv[s.id]['assigned'] = Array.new(per)

      for i in 0..per-1
        @sv[s.id]['assigned'][i] = vv_arr[idx].id

        vsa = VoterSubmissionAssignment.new
        vsa.voter_id = vv_arr[idx].id
        vsa.grant_submission_id = s.id
        vsa.save

        idx=idx+1

        if idx >= max
          idx = 0
        end
      end
    end

    redirect_to action: "index"
  end

  def init_artists
    @artists = Artist.all
  end

  def init_voters
    # verified voters
    @voters = Voter.all
    @verified_voters = Voter.where(verified: true)
    @verified_voters.each do |vv|
      vv.class_eval do
        attr_accessor :assigned
      end

      vv.assigned = Array.new
      VoterSubmissionAssignment.where("voter_id = ?",vv.id).each{|vsa| vv.assigned.push(vsa.grant_submission_id)}
    end
  end

  def init_submissions
    @results = Hash.new
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
  end

  def index
    vv_arr = @verified_voters.to_ary
    idx = 0
    max = vv_arr.size
    per = 3

    @sv = Hash.new

    @submissions = []
    if max > 0
      @submissions = GrantSubmission.where(grant_id: active_vote_grants).order(grant_id: :asc)

      @submissions.each do |s|
        @sv[s.id] = Hash.new

        @sv[s.id]['id'] = s.id
        @sv[s.id]['name'] = s.name
        @sv[s.id]['assigned'] = Array.new(per)

        for i in 0..per-1
          @sv[s.id]['assigned'][i] = vv_arr[idx].id

          idx=idx+1

          if idx >= max
            idx = 0
          end
        end
      end
    end
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
end
