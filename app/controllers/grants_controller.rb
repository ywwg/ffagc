class GrantsController < ApplicationController
  load_and_authorize_resource

  def index
  end

  def new
  end

  def adjust_grant_deadline
    date_attributes = %i[submit_start submit_end vote_start vote_end meeting_one meeting_two]
    date_attributes.each do |date_attr|
      date = @grant.send(date_attr)
      local_date = ActiveSupport::TimeZone.new('America/New_York').local_to_utc(date)
      @grant.send("#{date_attr}=", local_date)
    end
    @grant.save!
end

  def create
    if @grant.save
      adjust_grant_deadline
      redirect_to action: 'index'
    else
      render 'failure'
    end
  end

  def edit
    render 'new'
  end

  def update
    if @grant.update(resource_params)
      adjust_grant_deadline
      redirect_to action: 'index'
    else
      render 'new'
    end
  end

  private

  def resource_params
    params.require(:grant).permit(:name, :max_funding_dollars,
                                  :funding_levels_csv,
                                  :submit_start, :submit_end,
                                  :vote_start, :vote_end,
                                  :meeting_one, :meeting_two,
                                  :hidden)
  end
end
