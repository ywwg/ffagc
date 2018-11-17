class TagsController < ApplicationController
  load_and_authorize_resource

  def index
  end

  def update
  end

  def new
  end

  def create
    if @tag.save
      redirect_to grants_path
    else
      render 'failure'
    end
  end

  def tag_params
    params.require(:tag).permit(:name, :description)
  end
end
