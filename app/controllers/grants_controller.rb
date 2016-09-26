class GrantsController < ApplicationController
  before_filter :initialize_grant

  def initialize_grant
    @grant = Grant.new
  end
  
  def grant_params
    params.require(:grant).permit(:id, :name, :max_funding_dollars, :submit_start, :submit_end, :vote_start, :vote_end)
  end
  
  def index
  end
  
  def create
    if !admin_logged_in?
      redirect_to "/"
      return
    end
    @grant = Grant.new(grant_params)
    
    if @grant.save
      render "success"
    else
      render "failure"
    end
  end
  
  def modify
    begin
      @grant = Grant.find(params.permit(:id)[:id])
    rescue
      redirect_to action: "index"
      return
    end
    
    render "modify"
  end
  
  def update
    if !admin_logged_in?
      logger.warn "grant type modification without admin login"
      render "failure"
      return
    end
    
    @grant = Grant.find(params[:id])
    @grant.attributes = grant_params
    if @grant.save
      render "success"
    else
      render "failure"
    end
  end
end
