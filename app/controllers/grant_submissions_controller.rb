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
    if !artist_logged_in?
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
    if admin_logged_in?
      params.require(:grant_submission).permit(:id, :name, :grant_id, 
          :requested_funding_dollars, :proposal, :granted_funding_dollars,
          :funding_decision, :authenticity_token)
    else
      params.require(:grant_submission).permit(:id, :name, :grant_id, 
          :requested_funding_dollars, :proposal, :authenticity_token)
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

  def update
    @grant_submission = GrantSubmission.find(params[:id])
    
    if !modify_grant_ok?(@grant_submission)
      redirect_to "/"
      return
    end
    
    @grant_submission.name = grant_update_params[:name]
    if grant_update_params[:proposal] != ""
      @grant_submission.proposal = grant_update_params[:proposal]
    end
    @grant_submission.grant_id = grant_update_params[:grant_id]
    @grant_submission.requested_funding_dollars = grant_update_params[:requested_funding_dollars]
    
    if admin_logged_in?
      @grant_submission.granted_funding_dollars = grant_update_params[:granted_funding_dollars]
      @grant_submission.funding_decision = grant_update_params[:funding_decision]
    end

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
      @grant_submission = GrantSubmission.find(params.permit(:id, :authenticity_token)[:id])
      if !modify_grant_ok?(@grant_submission)
        redirect_to "/"
        return
      end
    rescue
      redirect_to "/"
      return
    end
    
    render "modify"
  end
  
  def grant_contract_params
    params.permit(:id, :format, :submission_id, :authenticity_token)
  end
  
  def generate_contract
    begin
      submission = GrantSubmission.find(grant_contract_params[:submission_id])
    rescue
      redirect_to "/"
      return  
    end
    if modify_grant_ok?(submission)
      redirect_to "/"
      return
    end
    if !grant_submission_funded?(:submission_id) 
      logger.warn "tried to generate contract for non-funded grant"
      redirect_to "/"
    end
    grant_name = Grant.find(submission.grant_id).name
    artist_name = Artist.find(submission.artist_id).name
    
    respond_to do |format|
      format.html
      format.pdf do
        pdf = GrantContract.new(grant_name, submission.name, artist_name, submission.requested_funding_dollars)
        send_data pdf.render, filename: 
          "#{submission.name}_#{grant_name}_Contract_#{DateTime.current.strftime("%Y%m%d")}.pdf",
          type: "application/pdf"
      end
    end
  end
end
