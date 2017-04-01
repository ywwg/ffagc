require 'grant_contract'

class GrantSubmissionsController < ApplicationController

  before_filter :initialize_grant_submission
  before_action :set_back_link

  def create
    if !artist_logged_in?
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
    @grant_submission = GrantSubmission.find(params[:id])

    if !modify_grant_ok?(@grant_submission)
      redirect_to "/"
      return
    end

    @grant_submission.destroy
    if admin_logged_in?
      redirect_to :controller => "admins", :action => "index"
    else
      redirect_to :controller => "artists", :action => "index"
    end
  end

  def update
    @grant_submission = GrantSubmission.find(params[:id])

    if !modify_grant_ok?(@grant_submission)
      redirect_to "/"
      return
    end

    if params[:commit] == "Delete Submission"
      destroy
      return
    end

    if params[:commit] == "Update Discussion"
      if admin_logged_in?
        if @grant_submission.questions != grant_update_params[:questions]
          @grant_submission.questions_updated_at = Time.zone.now
          @grant_submission.questions = grant_update_params[:questions]
        end
      end
      if @grant_submission.answers != grant_update_params[:answers]
        @grant_submission.answers_updated_at = Time.zone.now
        @grant_submission.answers = grant_update_params[:answers]
      end
    else
      # Default grant modify case
      @grant_submission.name = grant_update_params[:name]
      if grant_update_params[:proposal] != nil && grant_update_params[:proposal] != ""
        @grant_submission.proposal = grant_update_params[:proposal]
      end
      if grant_update_params[:grant_id] != nil
        @grant_submission.grant_id = grant_update_params[:grant_id]
      end
      @grant_submission.requested_funding_dollars = grant_update_params[:requested_funding_dollars]

      if admin_logged_in?
        @grant_submission.granted_funding_dollars = grant_update_params[:granted_funding_dollars]
        @grant_submission.funding_decision = grant_update_params[:funding_decision]
      end
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

  def index
  end

  def edit
    begin
      @grant_submission = GrantSubmission.find(params.permit(:id, :authenticity_token)[:id])
      if !modify_grant_ok?(@grant_submission)
        redirect_to "/"
        return
      end
    rescue
      redirect_to "/"
      return
    end

    @artist_email = Artist.find(@grant_submission.artist_id)[:email]

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
      @grant_submission = GrantSubmission.find(params.permit(:id, :authenticity_token)[:id])
    rescue
      redirect_to "/"
      return
    end

    # Don't show discussions for projects that don't belong to the artist.
    # Overridden if admin or verified voter is logged in
    if !admin_logged_in? && !verified_voter_logged_in?
      # In the case that nobody is logged in, we'll just display an error.
      # Artists trying to snoop on other people's discussions don't get the
      # benefit of knowing what they did wrong.
      if artist_logged_in?
        if current_artist.id != @grant_submission.artist_id
          redirect_to "/"
          return
        end
      end
    end

    @question_edit_disable = false
    if !admin_logged_in?
      @question_edit_disable = true
    end

    @answer_edit_disable = false
    if !artist_logged_in? && !admin_logged_in?
      @answer_edit_disable = true
    end

    @supplements = Proposal.where(grant_submission_id: @grant_submission.id)
    @proposal = Proposal.new
  end

  def generate_contract
    begin
      submission = GrantSubmission.find(grant_contract_params[:submission_id])
    rescue
      redirect_to "/"
      return
    end
    if !modify_grant_ok?(submission)
      redirect_to "/"
      return
    end
    if !grant_submission_funded?(submission.id)
      logger.warn "tried to generate contract for non-funded grant"
      redirect_to "/"
    end
    grant_name = Grant.find(submission.grant_id).name
    artist_name = Artist.find(submission.artist_id).name

    respond_to do |format|
      format.html
      format.pdf do
        now = DateTime.current
        pdf = GrantContract.new(grant_name, submission.name, artist_name,
            submission.requested_funding_dollars, now)
        send_data pdf.render, filename:
          "#{submission.name}_#{grant_name}_Contract_#{now.strftime("%Y%m%d")}.pdf",
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
    if admin_logged_in?
      params.require(:grant_submission).permit(:id, :name, :grant_id,
          :requested_funding_dollars, :proposal, :granted_funding_dollars,
          :funding_decision, :authenticity_token, :questions, :answers)
    else
      params.require(:grant_submission).permit(:id, :name, :grant_id,
          :requested_funding_dollars, :proposal, :authenticity_token, :answers)
    end
  end

  def modify_grant_ok?(submission)
    if admin_logged_in?
      logger.warn "admin logged in, allowing submission modification"
      return true
    end
    if !artist_logged_in?
      logger.warn "no admin or artist logged in, not allowing submission modification"
      return false
    end
    if current_artist.id != submission.artist_id
      logger.warn "grant modification artist id mismatch: #{@grant_submission.artist_id} != #{current_artist.id}, not allowing submission modification"
      return false
    end
    return true
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
