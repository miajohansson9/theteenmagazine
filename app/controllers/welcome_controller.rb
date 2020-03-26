class WelcomeController < ApplicationController
  before_action :show

  def index
    @posts_approved = Post.published.limit(40).order("publish_at desc")
    @postsranking = Post.published.limit(60).order("publish_at desc").dup.reorder("post_impressions desc")
  end

  def show
    set_meta_tags title: 'The Teen Magazine | An Online Magazine For Teens',
                  description: 'The Teen Magazine is an online magazine for teens covering all things lifestyle, beauty, fashion, health, academics, high school, and more... '
  end
end
