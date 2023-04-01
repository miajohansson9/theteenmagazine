class WelcomeController < ApplicationController
  before_action :show
  before_action :featured

  def featured
    @featured = Post.where.not(publish_at: nil).find_by(featured: true)
    @posts_approved_0 =
      Post
        .published
        .by_published_date
        .first(5)
        .insert(0, @featured)
        .compact
        .uniq[
        0..4
      ]
    @post_approved_0_ids = @posts_approved_0.map(&:id)
  end

  def get_category_1_welcome
    @posts_approved_1 =
      Post
        .published
        .trending
        .limit(3)
        .where(category_id: Category.find("interviews").id)
        .where.not(id: @post_approved_0_ids)
    render partial: "welcome/categories/category_1"
  end

  def get_category_2_welcome
    @posts_approved_2 =
      Post
        .published
        .trending
        .limit(3)
        .where(category_id: Category.find("student-life").id)
        .where.not(id: @post_approved_0_ids)
    render partial: "welcome/categories/category_2"
  end

  def get_category_3_welcome
    @posts_approved_3 =
      Post
        .published
        .trending
        .limit(3)
        .where(category_id: Category.find("opinion").id)
        .where.not(id: @post_approved_0_ids)
    render partial: "welcome/categories/category_3"
  end

  def get_category_4_welcome
    @posts_approved_4 =
      Post
        .published
        .trending
        .limit(6)
        .where(category_id: Category.find("beauty-style").id)
        .where.not(id: @post_approved_0_ids)
    render partial: "welcome/categories/category_4"
  end

  def get_recent_posts
    @category_ids = [
      Category.find("interviews").id,
      Category.find("student-life").id,
      Category.find("opinion").id,
      Category.find("beauty-style").id,
    ]
    @posts_approved_last =
      Post
        .published
        .by_published_date
        .where.not(category_id: @category_ids)
        .where.not(id: @post_approved_0_ids)
        .limit(9)
    render partial: "welcome/partials/recents"
  end

  def get_trending_posts
    @trending = Post.published.trending.limit(9)
    render partial: "welcome/partials/trending"
  end

  def show
    set_meta_tags title: "The Teen Magazine",
                  image: "https://www.theteenmagazine.com#{ActionController::Base.helpers.image_path("ttm.png")}",
                  description: "The Teen Magazine is an online magazine covering all things wellness, student life, academics, lifestyle, relationships, beauty and more.",
                  fb: {
                    app_id: "1190455601051741",
                  },
                  og: {
                    image: {
                      url: "https://www.theteenmagazine.com#{ActionController::Base.helpers.image_path("ttm.png")}",
                      alt: "The Teen Magazine",
                    },
                    site_name: "The Teen Magazine",
                    description: "The Teen Magazine is an online magazine covering all things wellness, student life, academics, lifestyle, relationships, beauty and more.",
                  },
                  article: {
                    publisher: "https://www.facebook.com/theteenmagazinee",
                  },
                  twitter: {
                    card: "summary_large_image",
                    site: "@theteenmagazin_",
                    title: "The Teen Magazine",
                    description: "The Teen Magazine is an online magazine covering all things wellness, student life, academics, lifestyle, relationships, beauty and more.",
                    image: "https://www.theteenmagazine.com#{ActionController::Base.helpers.image_path("ttm.png")}",
                    domain: "https://www.theteenmagazine.com/",
                  }
  end
end
