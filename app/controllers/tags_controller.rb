class TagsController < ApplicationController
  load_and_authorize_resource

  def create
    if @tag.save
      redirect_to grants_path
    else
      render 'failure'
    end
  end

  def edit
    render 'new'
  end

  def update
    if @tag.update(tag_params)
      redirect_to grants_path
    else
      render 'failure'
    end
  end

  def tag_params
    params.require(:tag).permit(:name, :description, :hidden)
  end
end
