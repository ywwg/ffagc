class VotersController < ApplicationController
    before_filter :initialize_voter

    def initialize_voter
      @voter = Voter.new
      @grants = Grant.all
    end

    def signup
    end

    def voter_params
      params.require(:voter).permit(:name, :password_digest, :password, :password_confirmation, :email)
    end

    def voter_survey_params
      params.require(:survey).permit(:has_attended_firefly, :not_applying_this_year, :will_read, :will_meet, :has_been_voter, :has_participated_other, :has_received_grant, :has_received_other_grant, :how_many_fireflies)
    end

    def voter_participation_params
      params.require(:grants_voters)
    end

    def create
      if Voter.exists?(email: voter_params[:email.downcase])
        flash[:warning] = "The email address #{voter_params[:email.downcase]} already exists in our system"
        render "signup_failure"
        return
      end

      @voter = Voter.new(voter_params)

      @voter.email = @voter.email.downcase

      if @voter.save
        # save survey
        voter_survey = VoterSurvey.new(voter_survey_params)
        voter_survey.voter_id = @voter.id
        voter_survey.save

        # save participation info
        voter_participation_params.each do |id, can_do|
          # sanity check that the grant id is real.
          if Grant.find(id) == nil
            next
          end
          if can_do == "0"
            next
          end
          grants_voter = GrantsVoter.new
          grants_voter.voter_id = @voter.id
          grants_voter.grant_id = id
          grants_voter.save
        end

        # Send email
        begin
          # Will need to be replaced with deliver_now
          UserMailer.account_activation("voters", @voter).deliver
        rescue
          flash[:warning] = "Error sending email confirmation"
          render "signup_failure"
          return
        end

        render "signup_success"
      else
        render "signup_failure"
      end
    end

    def update
      if !admin_logged_in?
        redirect_to "/"
        return
      end

      @voter = Voter.find(params[:id])
      voter_participation_params.each do |id, can_do|
        if Grant.find(id) == nil
          next
        end
        if can_do == "0"
          if GrantsVoter.exists?(voter_id: @voter.id, grant_id: id)
            GrantsVoter.find_by(voter_id: @voter.id, grant_id: id).destroy
          end
        else
          if GrantsVoter.exists?(voter_id: @voter.id, grant_id: id)
            next
          end
          grants_voter = GrantsVoter.new
          grants_voter.voter_id = @voter.id
          grants_voter.grant_id = id
          grants_voter.save
        end
      end

      redirect_to :controller => "admins", :action => "voters"
    end

    def index
      if !voter_logged_in?
        return
      end

      @grant_submissions = GrantSubmission.where(grant_id: active_vote_grants)

      # this is good for lace/temple
      # @grant_submissions = @grant_submissions.sort { |a,b| [a.grant_id,a.id] <=> [b.grant_id,b.id] }

      @grant_submissions = @grant_submissions.sort { |a,b| [a.name] <=> [b.name] }

      @votes = Hash.new

      @grant_submissions.each do |gs|
        gs.class_eval do
          attr_accessor :assigned
        end

        vote = Vote.where("voter_id = ? AND grant_submission_id = ?", current_voter.id, gs.id).take

        if !vote
          vote = Vote.new
          vote.voter_id = current_voter.id
          vote.grant_submission_id = gs.id
          vote.save
        end

        @votes[gs.id] = vote

        #assignments
        vsa = VoterSubmissionAssignment.where("voter_id = ? AND grant_submission_id = ?", current_voter.id, gs.id).take
        if vsa
          gs.assigned = 1
        else
          gs.assigned = 0
        end
      end

      @grant_submissions_assigned = @grant_submissions.select{|gs| gs.assigned == 1}
      @grant_submissions_unassigned = @grant_submissions.select{|gs| gs.assigned == 0}

      @grant_submissions_unassigned.sort_by {|gs| gs.grant_id}

      @grant_submissions_display = @grant_submissions_assigned
      @show_all = false
      if params[:all] == "true"
        @show_all = true
        @grant_submissions_display = @grant_submissions
      end
    end

  def vote
    @grant_submissions = GrantSubmission.where(grant_id: active_vote_grants)

    # Realistically, only one var will ever change at a time because the user
    # can only change one thing at once.  Really the submit function should
    # just pass the one item that changed.
    @grant_submissions.each do |gs|
      vote = Vote.where("voter_id = ? AND grant_submission_id = ?", current_voter.id, gs.id).take
      # nil means "was not set".  If the user sets to blank, it will be " ".
      if params['t'][gs.id.to_s] == nil
        next
      end

      changed = false
      if vote.score_t.to_s != params['t'][gs.id.to_s]
        vote.score_t = params['t'][gs.id.to_s]
        changed = true
      end
      if vote.score_c.to_s != params['c'][gs.id.to_s]
        vote.score_c = params['c'][gs.id.to_s]
        changed = true
      end
      if vote.score_f.to_s != params['f'][gs.id.to_s]
        vote.score_f = params['f'][gs.id.to_s]
        changed = true
      end
      if changed
        vote.save
      end
    end

    render :json => { }
  end
end
