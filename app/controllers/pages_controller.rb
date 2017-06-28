class PagesController < ApplicationController
  before_action :authenticate_user!, except: :privacy

  def criteria
  end

  def topics
  end

  def writing
  end

  def images
  end

  def styling
  end

  def privacy
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
