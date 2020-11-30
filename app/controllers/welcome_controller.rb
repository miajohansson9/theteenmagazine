class WelcomeController < ApplicationController
  before_action :show

  def index
    @featured = Post.published.where(featured: true).order("publish_at desc").first
    @featured = @featured.nil? ? Post.published.order("publish_at desc").first : @featured
    @posts_approved = Post.published.order("publish_at desc").limit(30)
    @posts_approved_0 = @posts_approved[0..4]
    @posts_approved_1 = @posts_approved.where(category_id: Category.find("student-life").id).reject{|p| @posts_approved_0.include? p}.slice(0, 3)
    @posts_approved_2 = @posts_approved.where(category_id: Category.find("opinion").id).reject{|p| @posts_approved_0.include? p}.slice(0, 3)
    @posts_approved_3 = @posts_approved.where(category_id: Category.find("culture").id).reject{|p| @posts_approved_0.include? p}.slice(0, 3)
    @posts_approved_4 = @posts_approved.where(category_id: Category.find("lifestyle").id).reject{|p| @posts_approved_0.include? p}.slice(0, 6)
    @featured_posts = @posts_approved_0 + @posts_approved_1 + @posts_approved_2 + @posts_approved_3 + @posts_approved_4
    @posts_approved_last = @posts_approved.reject{|p| @featured_posts.include? p}
    @postsranking = Post.published.where(:publish_at => (Time.now - 1.months)..Time.now).limit(7).order("post_impressions desc")
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
