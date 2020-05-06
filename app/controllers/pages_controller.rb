class PagesController < ApplicationController
  before_action :authenticate_user!, except: [:privacy, :team, :submitted, :subscribe, :reset, :reset_confirmation]
  layout "minimal", except: [:about, :team, :subscribe, :privacy, :reset]

  def subscribe
    @posts_approved = Post.published.all.order("created_at desc")
  end

  def team
  end

  def criteria
  end

  def topics
    @pitch = Pitch.new
    @categories = Category.all
  end

  def writing
    @post = current_user.posts.build
  end

  def images
  end

  def privacy
  end

  def about
  end

  def submitted
  end

  def reset
    @user = User.new
  end
end
