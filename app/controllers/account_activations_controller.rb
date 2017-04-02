class AccountActivationsController < ApplicationController
  before_action :set_user
  before_action :redirect_if_current_user_activated, only: [:show, :create]

  # this GET request action can edit a user
  def show
    if @user&.activation_token_valid?(params[:id])
      @user.activate!

      render 'show'
    end
  rescue ActiveRecord::ActiveRecordError => e
    render 'show'
  end

  # Reset activation token and send activation email
  # Currently doesn't have any sort of timeout and sends an email
  # so it could be abused.
  def create
    raise if @user.activated? || @user.nil?

    @user.create_activation_digest
    @user.save!

    UserMailer.account_activation(@type, @user).deliver_now

    redirect_to root_path
  rescue
    flash[:info] = 'Error sending email confirmation'
    render 'unactivated'
    return
  end

  def unactivated
  end

  private

  def redirect_if_current_user_activated
    if @user&.activated? && @user == current_user
      after_activate
    end
  end

  def set_user
    @type = params[:type]
    @email = params[:email]
    @user = UserFinder.find_by_email(@type, @email)
  end

  def after_activate
    flash[:info] = 'Account already activated.'
    redirect_to root_path
  end
end
