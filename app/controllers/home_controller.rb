class HomeController < ApplicationController    

  helper_method :artist_logged_in?, :voter_logged_in?, :admin_logged_in?

  #before_filter artist_logged_in?, except: [:show, :index]
    
  def index
  end

  def hello
  end

end
