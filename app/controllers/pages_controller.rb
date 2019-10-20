class PagesController < ApplicationController
  before_action :authenticate_user!, except: [:privacy, :team, :submitted, :subscribe]
  layout "minimal"

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

  def formatting
  end

  def checklist
  end

  def subscribe
    @posts_approved = Post.approved.all.order("created_at desc")
  end

  def team
    @users = User.order("posts_count DESC")
  end

  def ranking
    @posts = Post.all.order("created_at desc")
    @first_post = Post.first_rank.all
    @second_post = Post.second_rank.all
    @third_post = Post.third_rank.all
    @fourth_post = Post.fourth_rank.all
    @fifth_post = Post.fifth_rank.all
    @sixth_post = Post.sixth_rank.all
    @seventh_post = Post.seventh_rank.all
    @eighth_post = Post.eighth_rank.all
    @nineth_post = Post.nineth_rank.all
    @tenth_post = Post.tenth_rank.all
  end
end
