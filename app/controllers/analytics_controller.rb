class AnalyticsController < ApplicationController
  skip_before_action :verify_authenticity_token
  before_action :find_user
  before_action :authenticate_user!

  def find_user
    @user = User.find(params[:user_id])
  end

  def index
    redirect_to @user unless access
    @pagy, @user_posts =
    pagy(
      Post
        .where('collaboration like ?', "%#{@user.email}%")
        .or(Post.where(user_id: @user.id))
        .or(Post.where(partner_id: @user.id))
        .published
        .by_published_date,
        page: params[:page],
        items: 40,
    )
  end

  private

  def access
    current_user.admin? || current_user.editor? || current_user.id == @user.id
  end
end
