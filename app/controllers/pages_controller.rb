class PagesController < ApplicationController
  before_action :authenticate_user!, except: [:privacy, :team, :submitted, :subscribe]
  layout "minimal"

  def subscribe
    @posts_approved = Post.approved.all.order("created_at desc")
  end

  def team
    @users = User.order("posts_count DESC")
  end

  def ranking
    @posts = Post.all.order("created_at desc")
  end

  def criteria
  end

  def topics
  end

  def writing
    @post = current_user.posts.build
  end

  def images
  end

  def styling
  end

  def privacy
  end

  def about
  end

  def submitted
  end

end
