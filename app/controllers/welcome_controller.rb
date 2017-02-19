class WelcomeController < ApplicationController
  before_action :show

  def index
    @posts = Post.all.order("created_at desc")
    @posts_featured = Post.approved.all.order("created_at desc").first
    @posts_approved = Post.approved.all.order("created_at desc")
  end

  def show
    set_meta_tags title: 'THE TEEN MAGAZINE | An Online Magazine For Teens',
                  description: 'The Teen Magazine is an online magazine for teens covering all things lifestyle, beauty, fashion, health, academics, high school, and more... '
  end
end
