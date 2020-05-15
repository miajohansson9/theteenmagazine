# Set the host name for URL creation
SitemapGenerator::Sitemap.default_host = "https://www.theteenmagazine.com"

SitemapGenerator::Sitemap.adapter = Class.new(SitemapGenerator::FileAdapter) {
  def gzip(stream, data)
    stream.write(data)
    stream.close
    open(stream.path.sub(/\.gz/, ''), 'wb') do |file|
      file.write(data)
    end
  end
}.new

SitemapGenerator::Sitemap.create do
  # Put links creation logic here.
  #
  # The root path '/' and sitemap index file are added automatically for you.
  # Links are added to the Sitemap in the order they are specified.
  #
  # Usage: add(path, options={})
  #        (default options are used if you don't specify)
  #
  # Defaults: :priority => 0.5, :changefreq => 'weekly',
  #           :lastmod => Time.now, :host => default_host
  #
  # Examples:
  #
  # Add '/articles'
  #
  #   add articles_path, :priority => 0.7, :changefreq => 'daily'
  #
  # Add all articles:
  #
  add "/about-us", :priority => 0.8, :changefreq => 'monthly'
  add "/apply", :priority => 0.8, :changefreq => 'yearly'
  add "/contact-us", :priority => 0.8, :changefreq => 'yearly'
  add "/login", :priority => 0.5, :changefreq => 'yearly'

  Category.find_each do |category|
    add category_path(category), :lastmod => category.updated_at, :priority => 0.8
  end

  Post.published.find_each do |post|
    add post_path(post), :lastmod => post.updated_at, :priority => 0.5, :changefreq => 'never'
  end

  User.find_each do |user|
    if user.posts.published.any?
      add user_path(user), :lastmod => user.updated_at, :priority => 0.5
    end
  end
end
