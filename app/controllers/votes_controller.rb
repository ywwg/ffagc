class VotesController < ApplicationController
  load_and_authorize_resource only: [:index, :update]

  def index
    # TODO: use scope
    @grant_submissions = GrantSubmission.where(grant_id: voter_active_vote_grants(current_voter.id))

    # TODO: sort in scope or add sorting scope
    @grant_submissions = @grant_submissions.sort { |a,b| [a.name] <=> [b.name] }

    @votes = Hash.new

    @grant_submissions.each do |gs|
      gs.class_eval do
        attr_accessor :assigned
      end

      vote = current_voter.votes.where(grant_submission: gs).first_or_create

      @votes[gs.id] = vote

      #assignments
      vsa = current_voter.voter_submission_assignments.where(grant_submission: gs)

      if vsa.exists?
        gs.assigned = 1
      else
        gs.assigned = 0
      end
    end

    # TODO: use scopes
    @grant_submissions_assigned = @grant_submissions.select{|gs| gs.assigned == 1}
    @grant_submissions_unassigned = @grant_submissions.select{|gs| gs.assigned == 0}

    # TODO: sort in scope or add sorting scope
    @grant_submissions_unassigned.sort_by {|gs| gs.grant_id}

    if params[:all] == "true"
      @show_all = true
      @grant_submissions_display = @grant_submissions
    else
      @show_all = false
      @grant_submissions_display = @grant_submissions_assigned
    end
  end

  def update
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
