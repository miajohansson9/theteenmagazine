class WelcomeController < ApplicationController
  before_action :show
  
  def index
    @posts = Post.all.order("created_at desc")
    @projects = Project.all
    @posts_featured = Post.all.order("created_at desc").first
  end

  def show
    set_meta_tags title: 'The Teen Magazine',
                  description: 'This is a description'
  end
end
