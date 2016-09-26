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
end
