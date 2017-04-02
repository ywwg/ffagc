class ProposalsController < ApplicationController
  load_and_authorize_resource

  def destroy
    begin
      @proposal.destroy!
    rescue
      flash[:warning] = 'Error deleting supplemental document.'
    end

    # TODO consider have redirect_to param
    redirect_to edit_grant_submission_path(@proposal.grant_submission)
  end
end
