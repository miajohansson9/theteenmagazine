class WelcomeController < ApplicationController
  before_action :show

  def index
    @posts_approved = Post.published.limit(40).order("publish_at desc")
    @postsranking = Post.published.where(:publish_at => (Time.now - 3.months)..Time.now).order("post_impressions desc").limit(10)
  end

  def show
    set_meta_tags title: 'The Teen Magazine',
                  description: 'The Teen Magazine is an online magazine covering all things wellness, student life, academics, lifestyle, relationships, beauty and more.'
  end
end
