class ProposalsController < ApplicationController

  before_filter :verify_correct_artist

  def create
    @proposal = Proposal.new(proposal_params)
    if @proposal.save
      redirect_to grant_submission_discuss_path(grant_submission_id)
    else
      render "upload_failure"
    end
  end

  def destroy
    @proposal = Proposal.find(proposal_id)

    begin
      @proposal.destroy
      redirect_to grant_submission_discuss_path(grant_submission_id)
    rescue
      render "destroy_failure"
    end
  end

  private

  def grant_submission_id
    params[:grant_submission_id] || proposal_params[:grant_submission_id]
  end

  def proposal_id
    params[:id] || proposal_params[:id]
  end

  def proposal_params
    params.require(:proposal).permit(:grant_submission_id, :file, :id)
  end

  def verify_correct_artist
    # TODO: use cancan
    @proposal = Proposal.find(proposal_id)

    if admin_logged_in?
      return
    end

    if !current_artist
      redirect_to "/"
      return
    end
    begin
      @grant_submission = if @proposal.present?
        @proposal.grant_submission
      else
        GrantSubmission.find(grant_submission_id)
      end
    rescue
      redirect_to "/"
      return
    end
    if @grant_submission.artist_id != current_artist.id
      logger.warning "Attempt to upload supplement for submission not owned by current artist"
      redirect_to "/"
      return
    end
  end
end
