class WelcomeController < ApplicationController
  before_action :show

  def index
    @featured = Post.find_by(featured: true)
    @posts_approved_0 = Post.published.first(5).insert(0, @featured).compact.uniq[0..4]
    @category_ids = [Category.find('student-life').id, Category.find('opinion').id, Category.find('culture').id, Category.find('lifestyle').id]
    get_category_posts
    get_trending_posts
    get_recent_posts
  end

  def get_category_posts
    @posts_approved_1 = Post.published.limit(3).where(category_id: @category_ids[0])
    @posts_approved_2 = Post.published.limit(3).where(category_id: @category_ids[1])
    @posts_approved_3 = Post.published.limit(3).where(category_id: @category_ids[2])
    @posts_approved_4 = Post.published.limit(6).where(category_id: @category_ids[3])
  end

  def get_trending_posts
    @postsranking = Post.published.trending.limit(7)
  end

  def get_recent_posts
    @posts_approved_last = Post.published.where.not(category_id: @category_ids).limit(9)
  end

  def show
    set_meta_tags :title => 'The Teen Magazine',
                  :image => "https://www.theteenmagazine.com#{ActionController::Base.helpers.image_path('ttm.png')}",
                  :description => 'The Teen Magazine is an online magazine covering all things wellness, student life, academics, lifestyle, relationships, beauty and more.',
                  :fb => {
                    :app_id => "1190455601051741"
                  },
                  :og => {
                    :image => {
                      :url => "https://www.theteenmagazine.com#{ActionController::Base.helpers.image_path('ttm.png')}",
                      :alt => 'The Teen Magazine',
                    },
                    :site_name => "The Teen Magazine",
                    :description => 'The Teen Magazine is an online magazine covering all things wellness, student life, academics, lifestyle, relationships, beauty and more.',
                  },
                  :article => {
                    :publisher => "https://www.facebook.com/theteenmagazinee"
                  },
                  :twitter => {
                    :card => "summary_large_image",
                    :site => "@theteenmagazin_",
                    :title => "The Teen Magazine",
                    :description => "The Teen Magazine is an online magazine covering all things wellness, student life, academics, lifestyle, relationships, beauty and more.",
                    :image => "https://www.theteenmagazine.com#{ActionController::Base.helpers.image_path('ttm.png')}",
                    :domain => "https://www.theteenmagazine.com/"
                  }
  end
end
