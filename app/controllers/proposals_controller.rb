class ProposalsController < ApplicationController

  before_filter :verify_correct_artist

  def verify_correct_artist
    if admin_logged_in?
      return
    end

    if !current_artist
      redirect_to "/"
      return
    end
    begin
      @grant_submission = GrantSubmission.find(params.permit(:grant_submission_id, :authenticity_token)[:grant_submission_id])
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

  def proposal_params
    params.require(:proposal).permit(:grant_submission_id, :file, :id)
  end

  def create
    @proposal = Proposal.new(proposal_params)
    if @proposal.save
      redirect_to :controller => "grant_submissions", :action => "discuss",
          :id => proposal_params[:grant_submission_id]
    else
      render "upload_failure"
    end
  end

  def delete
    @proposal = Proposal.find(proposal_params[:id])
    @proposal.destroy
    redirect_to :controller => "grant_submissions", :action => "discuss",
          :id => proposal_params[:grant_submission_id]
  end
end
