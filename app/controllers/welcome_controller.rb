class WelcomeController < ApplicationController
  def index
    @posts = Post.all.limit(8).order("created_at desc")
    @projects = Project.all
  end
end
