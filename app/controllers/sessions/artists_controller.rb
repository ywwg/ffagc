class Sessions::ArtistsController < Sessions::BaseController

  alias_method :resource_logged_in?, :artist_logged_in?

  def type_name
    'artists'
  end

  def session_key
    :artist_id
  end

  def resource_by_email(email)
    Artist.find_by_email(email)
  end

  def form_action_path
    sessions_artist_path
  end

  def after_create_path
    grant_submissions_path
  end
end
