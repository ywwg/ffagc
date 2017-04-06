class AdminsController < ApplicationController
  load_and_authorize_resource

  def index
    @verified_voters = Voter.where(verified: true)
  end

  def new
  end

  def create
    @admin = Admin.new(admin_params)

    if @admin.save
      # Only assign the session to the new account if it's the first one.
      flash[:success] = "New admin <#{@admin.email}> created."

      unless session[:admin_id].present?
        session[:admin_id] = @admin.id
        redirect_to root_path
        return
      end

      # reset @admin so form is empty
      @admin = Admin.new
    end

    render 'new'
  end

  private

  def admin_params
    params.require(:admin).permit(:name, :email, :password, :password_confirmation)
  end
end
