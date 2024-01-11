class WelcomeController < ApplicationController
  def get_trending_posts
    @trending = Post.published.trending.limit(9)
    render partial: "welcome/partials/trending"
  end

  def index
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

    @categories = Category.active.order("rank asc").limit(5)
    @category_1 = @categories[0]
    @category_2 = @categories[1]
    @category_3 = @categories[2]
    @category_4 = @categories[3]

    @category_1_posts = @category_1.posts.published.by_published_date.where.not(id: @post_approved_0_ids).limit(3)
    @category_2_posts = @category_2.posts.published.by_published_date.where.not(id: @post_approved_0_ids).limit(3)
    @category_3_posts = @category_3.posts.published.by_published_date.where.not(id: @post_approved_0_ids).limit(6)
    @category_4_posts = @category_4.posts.published.by_published_date.where.not(id: @post_approved_0_ids).limit(3)
    
    @category_ids = @categories.map(&:id)
    @posts_approved_last =
      Post
        .published
        .by_published_date
        .where.not(category_id: @category_ids)
        .where.not(id: @post_approved_0_ids)
        .limit(9)

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
                    site: "@ttm_magazine",
                    title: "The Teen Magazine",
                    description: "The Teen Magazine is an online magazine covering all things wellness, student life, academics, lifestyle, relationships, beauty and more.",
                    image: "https://www.theteenmagazine.com#{ActionController::Base.helpers.image_path("ttm.png")}",
                    domain: "https://www.theteenmagazine.com/",
                  }
  end
end
