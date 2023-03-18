class LikesController < ApplicationController
  before_action :find_like, only: %i[destroy]

  def new
    if current_user.present?
      @like = current_user.likes.build(like_params)
    else
      @like = Like.new(like_params)
    end
  end

  def destroy
    @like.destroy
  end

  def create
    if current_user.present?
      @like = current_user.likes.build(like_params)
    else
      @like = Like.new(like_params)
    end
  end

  private

  def like_params
    params
      .require(:like)
      .permit(:id, :user_id, :comment_id, :cookie)
  end

  def find_like
    @like = Like.find(params[:id])
  end
end
