class ArtistsController < ApplicationController
  load_and_authorize_resource only: [:index, :show]

  before_filter :initialize_user, except: [:show]

  def show
  end

  def signup
    @artist.artist_survey ||= ArtistSurvey.new
  end

  def create
    if Artist.exists?(email: artist_params[:email].downcase)
      flash[:warning] = "The email address #{artist_params[:email.downcase]} already exists in our system"
      render "signup_failure"
      return
    end

    @artist = Artist.new(artist_params)
    @artist.email = @artist.email.downcase

    if @artist.save
      # save optional survey
      artist_survey = ArtistSurvey.new(artist_survey_params)
      artist_survey.artist_id = @artist.id
      artist_survey.save

      # Send email!
      begin
        UserMailer.account_activation("artists", @artist).deliver_now
        logger.info "email: artist account activation sent to #{@artist.email}"
      rescue
        flash[:warning] = "Error sending email confirmation"
        render "signup_failure"
        return
      end

      render "signup_success"
    else
      @artist.artist_survey ||= ArtistSurvey.new(artist_survey_params)
      render "signup"
    end
  end

  private

  def initialize_user
    @artist = Artist.new
  end

  def artist_params
    params.require(:artist).permit(:name, :password_digest, :password,
        :password_confirmation, :email, :contact_name, :contact_phone,
        :contact_street, :contact_city, :contact_state, :contact_zipcode,
        :contact_country)
  end

  def artist_survey_params
    params.require(:artist).require(:artist_survey).permit(:has_attended_firefly,
        :has_attended_firefly_desc, :has_attended_regional,
        :has_attended_regional_desc, :has_attended_bm, :has_attended_bm_desc,
        :can_use_as_example)
  end
end
