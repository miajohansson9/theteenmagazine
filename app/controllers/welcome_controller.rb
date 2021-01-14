class WelcomeController < ApplicationController
  before_action :show

  def index
    @featured = Post.where.not(publish_at: nil).find_by(featured: true)
    @posts_approved_0 = Post.published.by_published_date.first(5).insert(0, @featured).compact.uniq[0..4]
    @posts_approved_1 = Post.published.by_published_date.limit(3).where(category_id: Category.find('student-life').id)
  end

  def get_category_2_welcome
    @posts_approved_2 = Post.published.by_published_date.limit(3).where(category_id: Category.find('opinion').id)
    render partial: "welcome/categories/category_2"
  end

  def get_category_3_welcome
    @posts_approved_3 = Post.published.by_published_date.limit(3).where(category_id: Category.find('culture').id)
    render partial: "welcome/categories/category_3"
  end

  def get_category_4_welcome
    @posts_approved_4 = Post.published.by_published_date.limit(6).where(category_id: Category.find('lifestyle').id)
    render partial: "welcome/categories/category_4"
  end

  def get_trending_posts
    @trending = Post.published.trending.limit(7)
    render partial: "welcome/partials/trending"
  end

  def get_recent_posts
    @category_ids = [Category.find('student-life').id, Category.find('opinion').id, Category.find('culture').id, Category.find('lifestyle').id]
    @posts_approved_last = Post.published.by_published_date.where.not(category_id: @category_ids).limit(9)
    render partial: "welcome/partials/recents"
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
