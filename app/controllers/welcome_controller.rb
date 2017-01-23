class WelcomeController < ApplicationController
  def index
    @posts = Post.all.order("created_at desc")
    @projects = Project.all
    @posts_featured = Post.all.order("created_at desc").first
  end
end
