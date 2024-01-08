module CategoriesHelper
  def populate_published(days_ago)
    @index = 0
    @bucket = Time.now - (days_ago * 1.day) + 1.day
    @published = Array.new(days_ago, 0)
    @posts = Post.published.where(publish_at: (Time.now - (1.day * days_ago))..Time.now).order("publish_at asc")
    @posts.each do |post|
      while post.publish_at > @bucket
        # post was published past the bucket time
        @bucket = @bucket + 1.day
        @index = @index + 1
      end
      @published[@index] = @published[@index] + 1
    end
    return @published
  end

  def populate_published_in_category(days_ago, category)
    @index = 0
    @bucket = Time.now - (days_ago * 1.day) + 1.day
    @published_in_category = Array.new(days_ago, 0)
    @posts = Post.published.where(publish_at: (Time.now - (1.day * days_ago))..Time.now).where(category_id: category.id).order("publish_at asc")
    @posts.each do |post|
      while post.publish_at > @bucket
        @bucket = @bucket + 1.day
        @index = @index + 1
      end
      @published_in_category[@index] = @published_in_category[@index] + 1
    end
    return @published_in_category
  end

  def populate_started_in_category(days_ago, category)
    @index = 0
    @bucket = Time.now - (days_ago * 1.day) + 1.day
    @started_in_category = Array.new(days_ago, 0)
    @posts = Post.where(created_at: (Time.now - (1.day * days_ago))..Time.now).where(category_id: category.id).order("created_at asc")
    @posts.each do |post|
      while post.created_at > @bucket
        # post was published past the bucket time
        @bucket = @bucket + 1.day
        @index = @index + 1
      end
      @started_in_category[@index] = @started_in_category[@index] + 1
    end
    return @started_in_category
  end

  def populate_published_in_all_categories(days_ago)
    @index = 0
    @bucket = Time.now - (days_ago * 1.day) + 1.day
    @published = Array.new(days_ago, 0)
    @posts = Post.published.where(publish_at: (Time.now - (1.day * days_ago))..Time.now).order("publish_at asc")
    @posts.each do |post|
      while post.publish_at > @bucket
        @bucket = @bucket + 1.day
        @index = @index + 1
      end
      @published[@index] = @published[@index] + 1
    end
    return @published
  end

  def populate_started_in_all_categories(days_ago)
    @index = 0
    @bucket = Time.now - (days_ago * 1.day) + 1.day
    @started = Array.new(days_ago, 0)
    @posts = Post.where(created_at: (Time.now - (1.day * days_ago))..Time.now).order("created_at asc")
    @posts.each do |post|
      while post.created_at > @bucket
        # post was published past the bucket time
        @bucket = @bucket + 1.day
        @index = @index + 1
      end
      @started[@index] = @started[@index] + 1
    end
    return @started
  end
end
