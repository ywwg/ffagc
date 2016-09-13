class ArtistsController < ApplicationController

  before_filter :initialize_user

  def initialize_user
    @artist = Artist.new
  end

  def signup
  end

  def artist_params
    params.require(:artist).permit(:name, :password_digest, :password, :password_confirmation, :email, :contact_name, :contact_phone, :contact_street, :contact_city, :contact_state)
  end

  def artist_survey_params
    params.require(:survey).permit(:has_attended_firefly, :has_attended_firefly_desc, :has_attended_regional, :has_attended_regional_desc, :has_attended_bm, :has_attended_bm_desc, :can_use_as_example)
  end

  def create
    @artist = Artist.new(artist_params)
    @artist.email = @artist.email.downcase

    if @artist.save
      # log in
      session[:artist_id] = @artist.id

      # save optional survey
      artist_survey = ArtistSurvey.new(artist_survey_params)
      artist_survey.artist_id = @artist.id
      artist_survey.save

      render "signup_success"
    else
      render "signup_failure"
    end
  end

  def index
    if(!current_artist)
        return
    end
    
    @grant_submissions = GrantSubmission.where(artist_id: [current_artist.id])
  end
  
  def delete_params
    params.require(:grant_id)
  end
  
  def delete_grant
    @submission = GrantSubmission.find(params[:grant_id])
    if @submission != nil
      # Also should delete pdf from filesystem
      @submission.destroy
    end
    
    redirect_to action: "index"
  end

end
