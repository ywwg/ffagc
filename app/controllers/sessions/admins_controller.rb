class Sessions::AdminsController < Sessions::BaseController

  alias_method :resource_logged_in?, :admin_logged_in?

  def type_name
    'admins'
  end

  def session_key
    :admin_id
  end

  def resource_by_email(email)
    Admin.find_by_email(email)
  end

  def form_action_path
    sessions_admin_path
  end

  def after_create_path
    admins_grant_submissions_path
  end
end
