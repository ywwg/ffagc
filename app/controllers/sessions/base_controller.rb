class Sessions::BaseController < ApplicationController
  before_action :set_form_action_path

  def new
    if resource_logged_in?
      redirect_to after_create_path
    end

    render 'new'
  end

  def create
    @email = normalize_email(params[:session][:email])
    @resource = resource_by_email(@email)

    if @resource.present? && requires_activation? && !@resource.activated?
      redirect_to account_activations_unactivated_path(type: type_name, email: @email)
    end

    if @resource&.authenticate(params[:session][:password])
      session[session_key] = @resource.id

      redirect_to after_create_path
      return
    end

    @show_error = true
    render 'new'
  end

  def destroy
    session[session_key] = ''

    redirect_to after_delete_path
  end

  protected

  def type_name
    raise NotImplementedError
  end

  def session_key
    raise NotImplementedError
  end

  def form_action_path
    raise NotImplementedError
  end

  def resource_by_email(email)
    raise NotImplementedError
  end

  def resource_logged_in?
    raise NotImplementedError
  end

  def after_create_path
    root_path
  end

  def after_delete_path
    root_path
  end

  def requires_activation?
    true
  end

  def set_form_action_path
    @form_action_path = form_action_path
  end

  def normalize_email(email)
    email.strip.downcase
  end
end
