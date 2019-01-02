class GrantsController < ApplicationController
  include GrantHelper

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
      render 'failure'
    end
  end

  # This is called via AJAX to make the forms useful. Returns the funding levels
  # for the given grant id in two ways -- one pretty, for display, and the
  # other as a list of founding lower and upper bounds. In the case of single
  # values, we return the same value and the lower and upper bound.
  def levels
    grant_id = params[:id]
    grant = Grant.find(grant_id)
    if grant == nil
      render :json => {}
      return
    end

    levels_array = []
    grant.funding_levels_csv.split(',').each do |token|
      limits = token.split("-")
      if limits.length == 1
        limit = Integer(limits[0])
        levels_array.append([limit, limit])
      elsif limits.length == 2
        lower = Integer(limits[0])
        upper = Integer(limits[1])
        levels_array.append([lower, upper])
      end
    end

    # XXX: We're not supposed to be doing display formatting in the controller
    # like this.
    render :json => {
      pretty: funding_levels_pretty(grant),
      levels: levels_array
    }
  end

  private

  def resource_params
    params.require(:grant).permit(:name, :contract_template,
                                  :funding_levels_csv,
                                  :submit_start, :submit_end,
                                  :vote_start, :vote_end,
                                  :meeting_one, :meeting_two,
                                  :hidden)
  end
end
