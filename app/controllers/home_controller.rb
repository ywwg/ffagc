class HomeController < ApplicationController

  # I think this gets around these functions being private? Not sure.
  helper_method :artist_logged_in?, :voter_logged_in?, :verified_voter_logged_in?, :admin_logged_in?

  #before_filter artist_logged_in?, except: [:show, :index]

  def index
  end

  def hello
  end

end
