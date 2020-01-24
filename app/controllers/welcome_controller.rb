class WelcomeController < ApplicationController
  before_action :show

  def index
    @postsranking = Post.approved.limit(30).order("post_impressions desc")
    @posts_approved = Post.approved.limit(40).order("created_at desc")
  end

  def show
    set_meta_tags title: 'The Teen Magazine | An Online Magazine For Teens',
                  description: 'The Teen Magazine is an online magazine for teens covering all things lifestyle, beauty, fashion, health, academics, high school, and more... '
  end
end
