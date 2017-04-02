require 'grant_contract'

class GrantSubmissionsController < ApplicationController

  before_filter :initialize_grant_submission
  before_action :set_back_link

  def create
    if !artist_logged_in?
      redirect_to root_path
      return
    end

    @grant_submission = GrantSubmission.new(grant_submission_params)

    @grant_submission.artist_id = current_artist.id

    if @grant_submission.save
      redirect_to :controller => "artists", :action => "index"
    else
      render 'new'
    end
  end

  def destroy
    @grant_submission = GrantSubmission.where(id: params[:id]).first
    authorize! :destroy, @grant_submission

    @grant_submission&.destroy!

    redirect_to action: 'index'
  end

  def update
    @grant_submission = GrantSubmission.find(params[:id])
    authorize! :update, @grant_submission

    @grant_submission.attributes = grant_update_params

    if @grant_submission.questions_changed?
      @grant_submission.questions_updated_at = Time.zone.now
    end

    if @grant_submission.answers_changed?
      @grant_submission.answers_updated_at = Time.zone.now
    end

    if admin_logged_in?
      @grant_submission.granted_funding_dollars = grant_update_params[:granted_funding_dollars]
      @grant_submission.funding_decision = grant_update_params[:funding_decision]
    end

    if @grant_submission.save
      if admin_logged_in?
        redirect_to :controller => "admins", :action => "index"
      else
        redirect_to :controller => "artists", :action => "index"
      end
    else
      render 'new'
    end
  end

  def show
    @grant_submission = GrantSubmission.find(params[:id])
    authorize! :show, @grant_submission
  end

  def index
    authorize! :index, GrantSubmission
    @grant_submissions = GrantSubmission.accessible_by(current_ability)

    @celebrate_funded = artist_logged_in? && @grant_submissions.funded.exists?
  end

  def edit
    @grant_submission = GrantSubmission.find(params.permit(:id, :authenticity_token)[:id])
    authorize! :edit, @grant_submission

    # Don't allow an artist to decide post-decision that they want a different
    # grant category.
    @grant_change_disable = false
    if @grant_submission.funding_decision && !admin_logged_in?
      @grant_change_disable = true
    end

    render 'new'
  end

  def discuss
    begin
      @grant_submission = GrantSubmission.find(params[:grant_submission_id] || params[:id])
    rescue
      redirect_to "/"
      return
    end

    authorize! :show, @grant_submission

    @question_edit_disable = false
    if !admin_logged_in?
      @question_edit_disable = true
    end

    @answer_edit_disable = false
    if !artist_logged_in? && !admin_logged_in?
      @answer_edit_disable = true
    end

    @proposal = Proposal.new
  end

  def generate_contract
    @grant_submission = GrantSubmission.find(params[:grant_submission_id])
    authorize! :read, @grant_submission

    if !grant_submission_funded?(@grant_submission.id)
      flash[:error] = "Grant Submission must be funded to create contract"
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

  def initialize_grant_submission
    @grant_submission = GrantSubmission.new
  end

  def grant_submission_params
    params.require(:grant_submission).permit(:name, :proposal, :grant_id, :requested_funding_dollars)
  end

  def grant_update_params
    allowed_params = [:name, :grant_id, :requested_funding_dollars, :answers, :proposal]

    if admin_logged_in?
      allowed_params.push(:granted_funding_dollars, :funding_decision, :questions)
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
