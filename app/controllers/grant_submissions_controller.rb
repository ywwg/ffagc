require 'grant_contract'

class GrantSubmissionsController < ApplicationController
  load_and_authorize_resource

  before_action :set_back_link

  def create
    @grant_submission.artist_id = current_artist.id

    if @grant_submission.save
      redirect_to artists_path
    else
      render 'new'
    end
  end

  def destroy
    @grant_submission&.destroy!

    redirect_to action: 'index'
  end

  def update
    @grant_submission.attributes = grant_update_params

    if admin_logged_in?
      @grant_submission.granted_funding_dollars = grant_update_params[:granted_funding_dollars]
      @grant_submission.funding_decision = grant_update_params[:funding_decision]
    end

    if @grant_submission.save
      if admin_logged_in?
        redirect_to admins_path
      else
        redirect_to artists_path
      end
    else
      render 'new'
    end
  end

  def show
  end

  def index
    @celebrate_funded = artist_logged_in? && @grant_submissions.funded.exists?
  end

  def edit
    # Don't allow an artist to decide post-decision that they want a different
    # grant category.
    @grant_change_disable = false
    if @grant_submission.funding_decision && !admin_logged_in?
      @grant_change_disable = true
    end

    render 'new'
  end

  def discuss
    @proposal = Proposal.new
  end

  def generate_contract
    @grant_submission = GrantSubmission.find(params[:grant_submission_id])
    authorize! :read, @grant_submission

    if !grant_submission_funded?(@grant_submission.id)
      flash[:danger] = "Grant Submission must be funded to create contract"
      logger.warn "tried to generate contract for non-funded grant"
      redirect_to "/"
    end

    grant_name = @grant_submission.grant.name
    artist_name = @grant_submission.artist.name

    respond_to do |format|
      format.html
      format.pdf do
        now = DateTime.current
        pdf = GrantContract.new(grant_name, @grant_submission.name, artist_name,
            @grant_submission.requested_funding_dollars, now)
        send_data pdf.render, filename:
          "#{@grant_submission.name}_#{grant_name}_Contract_#{now.strftime("%Y%m%d")}.pdf",
          type: "application/pdf"
      end
    end
  end

  private

  def grant_submission_params
    params.require(:grant_submission).permit(:name, :proposal, :grant_id, :requested_funding_dollars)
  end

  def grant_update_params
    allowed_params = [:name, :grant_id, :requested_funding_dollars, :proposal]

    if admin_logged_in?
      allowed_params.push(:granted_funding_dollars, :funding_decision)
    end

    if can? :edit_questions, GrantSubmission
      allowed_params.push(:questions)
    end

    if can? :edit_answers, GrantSubmission
      allowed_params.push(:answers)
    end

    par = params.require(:grant_submission).permit(allowed_params)

    # TODO this works but doesn't seem like the correct way
    proposal_attributes = params.require(:grant_submission).permit(proposals_attributes: :file)["proposals_attributes"]
    if proposal_attributes.present?
      par["proposals_attributes"] = [proposal_attributes]
    end

    par
  end

  def grant_contract_params
    params.permit(:id, :format, :submission_id, :authenticity_token)
  end

  def set_back_link
    @back_link = if admin_logged_in?
      admins_submissions_path
    elsif artist_logged_in?
      artists_path
    else
      grant_submissions_path
    end
  end
end
