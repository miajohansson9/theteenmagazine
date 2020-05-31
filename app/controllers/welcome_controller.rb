class WelcomeController < ApplicationController
  before_action :show

  def index
    @posts_approved = Post.published.limit(40).order("publish_at desc")
    @postsranking = Post.published.where(:publish_at => (Time.now - 3.months)..Time.now).order("post_impressions desc").limit(8)
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
