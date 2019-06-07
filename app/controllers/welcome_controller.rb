class WelcomeController < ApplicationController
  before_action :show

  def index
    @posts = Post.all.order("created_at desc")
    @posts_featured = Post.approved.all.order("created_at desc").first
    @posts_approved = Post.approved.all.order("created_at desc")
    @posts_approved_academics = Post.academics.all.order("created_at desc")
    @posts_approved_getinvolved = Post.get_involved.all.order("created_at desc")
    @posts_approved_health = Post.health.all.order("created_at desc")
    @category_fashion = Category.first
    @category_beauty = Category.second
    @category_entertainment = Category.third
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

  def show
    set_meta_tags title: 'The Teen Magazine | An Online Magazine For Teens',
                  description: 'The Teen Magazine is an online magazine for teens covering all things lifestyle, beauty, fashion, health, academics, high school, and more... '
  end
end
