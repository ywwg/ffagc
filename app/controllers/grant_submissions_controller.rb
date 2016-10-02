require 'grant_contract'

class GrantSubmissionsController < ApplicationController

  before_filter :initialize_grant_submission

  def initialize_grant_submission
    @grant_submission = GrantSubmission.new
  end

  def grant_submission_params
    params.require(:grant_submission).permit(:name, :proposal, :grant_id, :requested_funding_dollars)
  end

  def create
    if !current_artist
      return
    end

    @grant_submission = GrantSubmission.new(grant_submission_params)

    @grant_submission.artist_id = current_artist.id

    if @grant_submission.save
      render "success"
    else
      render "failure"
    end
  end
  
  def grant_update_params
    params.require(:grant_submission).permit(:id, :name, :grant_id, :requested_funding_dollars, :proposal)
  end

  def update
    @grant_submission = GrantSubmission.find(params[:id])
    
    if @grant_submission.artist_id != current_artist.id
      logger.warn "grant modification artist id mismatch: #{@grant_submission.artist_id} != #{current_artist.id}"
      if admin_logged_in
        logger.warn "OVERRIDE because admin logged in"
      else
        render "failure"
        return
      end
    end
    
    @grant_submission.name = grant_update_params[:name]
    if grant_update_params[:proposal] != ""
      @grant_submission.proposal = grant_update_params[:proposal]
    end
    @grant_submission.grant_id = grant_update_params[:grant_id]
    @grant_submission.requested_funding_dollars = grant_update_params[:requested_funding_dollars]

    if @grant_submission.save
      if admin_logged_in? 
        render "success_admin"
      else
        render "success_modify"
      end
    else
      if admin_logged_in?
        render "failure_admin"
      else
        render "failure_modify"
      end
    end
  end

  def index
  end
  
  def modify
    begin
      @grant_submission = GrantSubmission.find(params.permit(:id)[:id])
      if @grant_submission.artist_id != current_artist.id
        logger.warn "grant modification artist id mismatch #{@grant_submission.artist_id} != #{current_artist.id}"
        redirect_to "/"
        return
      end
    rescue
      redirect_to action: "index"
      return
    end
    
    render "modify"
  end
  
  def show
    @grant_submission = GrantSubmission.find(1)
    respond_to do |format|
      format.html
      format.pdf do
        pdf = GrantContract.new("Creatibity", "Nevermore", "Owen", 1000)
        send_data pdf.render, filename: 
          "nevermore_contract_todaysdate.pdf",
          type: "application/pdf"
      end
    end
  end
end
