class AnalyticsController < ApplicationController
  skip_before_filter :verify_authenticity_token
  before_action :find_user
  before_action :authenticate_user!
  load_and_authorize_resource
  layout "minimal"

  def find_user
    @user = User.find(params[:user_id])
  end

  def index
    redirect_to @user unless access
    @posts_by_impressions = @user.posts.published.order("post_impressions desc")
    @posts = @user.posts.published.order("publish_at desc")
  end

  private

  def access
    @user.admin || @user.editor || current_user.id == @user.id
  end

end
