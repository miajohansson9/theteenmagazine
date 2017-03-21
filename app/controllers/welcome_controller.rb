class WelcomeController < ApplicationController
  before_action :show

  def index
    @posts = Post.all.order("created_at desc")
    @posts_featured = Post.approved.all.order("created_at desc").first
    @posts_approved = Post.approved.all.order("created_at desc")
    @posts_approved_fashion = Post.fashion.all.order("created_at desc")
    @posts_approved_beauty = Post.beauty.all.order("created_at desc")
    @posts_approved_fitness = Post.fitness.all.order("created_at desc")
    @posts_approved_tips = Post.tips.all.order("created_at desc")
    @posts_approved_academics = Post.academics.all.order("created_at desc")
    @posts_approved_entertainment = Post.entertainment.all.order("created_at desc")
    @posts_approved_trends = Post.trends.all.order("created_at desc")
    @posts_approved_others = Post.other.all.order("created_at desc")
    @category_fashion = Category.first
    @category_beauty = Category.second
    @category_entertainment = Category.third
  end

  def show
    set_meta_tags title: 'THE TEEN MAGAZINE | An Online Magazine For Teens',
                  description: 'The Teen Magazine is an online magazine for teens covering all things lifestyle, beauty, fashion, health, academics, high school, and more... '
  end
end
