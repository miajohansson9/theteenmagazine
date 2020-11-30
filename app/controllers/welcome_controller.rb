class WelcomeController < ApplicationController
  before_action :show

  def index
    @featured = Post.published.where(featured: true).order("publish_at desc").first
    @featured = @featured.nil? ? Post.published.order("publish_at desc").first : @featured
    @posts_approved_0 = Post.published.order("publish_at desc").to_a.insert(0, @featured).uniq.slice(0, 5)
    @posts_approved_1 = Category.find("student-life").posts.published.order("publish_at desc").reject{|p| @posts_approved_0.include? p}.slice(0, 3)
    @posts_approved_2 = Category.find("opinion").posts.published.order("publish_at desc").reject{|p| @posts_approved_0.include? p}.slice(0, 3)
    @posts_approved_3 = Category.find("culture").posts.published.order("publish_at desc").reject{|p| @posts_approved_0.include? p}.slice(0, 3)
    @posts_approved_4 = Category.find("lifestyle").posts.published.order("publish_at desc").reject{|p| @posts_approved_0.include? p}.slice(0, 6)
    @featured_posts = @posts_approved_0 + @posts_approved_1 + @posts_approved_3 + @posts_approved_4
    @posts_approved_last = Post.published.order("publish_at desc").reject{|p| @featured_posts.include? p}.slice(0, 15)
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
