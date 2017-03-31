class GrantsController < ApplicationController
  load_and_authorize_resource

  def index
  end

  def new
  end

  def create
    if @grant.save
      redirect_to action: 'index'
    else
      render 'failure'
    end
  end

  def edit
    unless @grant.present?
      redirect_to action: 'index'
      return
    end

    render 'new'
  end

  def update
    if @grant.update(resource_params)
      redirect_to action: 'index'
    else
      render 'failure'
    end
  end

  private

  def resource_params
    params.require(:grant).permit(:name, :max_funding_dollars,
                                  :submit_start, :submit_end,
                                  :vote_start, :vote_end,
                                  :meeting_one, :meeting_two,
                                  :hidden)
  end
end
