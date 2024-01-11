namespace :content do
  task :migrate_interview_articles => :environment do |t, args|
    Category.find('interviews').posts.each do |post|
      post.update_column('is_interview', true)
      puts "Updated post https://www.theteenmagazine.com/#{post.slug}"
    end
  end

  task :migrate_interview_pitches => :environment do |t, args|
    Category.find('interviews').pitches.each do |pitch|
      pitch.update_column('is_interview', true)
      puts "Updated pitch https://www.theteenmagazine.com/pitches/#{pitch.slug}"
    end
  end

  task :calculate_category_scores => :environment do |t, args|
    @categories = Category.active
    @category_scores = Hash.new
    puts ""
    @categories.each do |category|
      @pageviews = 0
      @comments = 0
      @posts = category.posts.published.where(publish_at: (Time.now - 1.month)..Time.now)
      @articles = @posts.count
      @posts.each do |post|
        @comments = @comments + post.comments.published.count
        @pageviews = @pageviews + post.post_impressions
      end
      @score = @comments * 2 + @pageviews + @articles * 3
      @category_scores[category.id] = @score
      puts "#{category.name}"
      puts "[#{@score}] Articles: #{@articles}, Pageviews: #{@pageviews}, Comments: #{@comments}"
      puts ""
    end
    # Sort the categories by their scores in descending order
    sorted_categories = @category_scores.sort_by { |_id, score| -score }

    # Print each category with its rank and score
    sorted_categories.each_with_index do |(category_id, score), index|
      category = Category.find(category_id)
      puts "Rank #{index + 1}: Category #{category.name}"
      category.update_column("rank", index + 1)
    end
  end

  task :delete_old_images, [:should_delete] => :environment do |t, args|
    Post.published.where(agree_to_image_policy: [false, nil]).each do |post|
      begin
        if args[:should_delete].eql? 'true'
          post.content = post.content.gsub(/<img[^>]*>/, '')
          post.save(:validate => false)
          puts "Deleted all the images in https://www.theteenmagazine.com/#{post.slug}"
        else
          img_src_links = post.content.scan(/<img[^>]*src\s*=\s*['"]([^'"]*)['"][^>]*>/).flatten
          puts img_src_links
        end
      rescue
        puts "Rescued from Error. Failed to delete images in post https://www.theteenmagazine.com/#{post.slug}"
      end
    end
  end

  task :optimize_all_recent_posts => :environment do |t, args|
    Post.published.where(publish_at: (Time.now - 1.day)..Time.now).each do |post|
      begin
        optimize_paragraph_length("https://www.theteenmagazine.com/#{post.slug}")
      rescue
        puts "Rescued from Error. Failed to optimize post https://www.theteenmagazine.com/#{post.slug}"
      end
    end
  end

  task :optimize_all_posts, [:limit] => :environment do |t, args|
    @limit = args[:limit].nil? ? 100 : Integer(args[:limit])
    Post.published.order("publish_at asc").limit(@limit).each do |post|
      begin
        optimize_paragraph_length("https://www.theteenmagazine.com/#{post.slug}")
      rescue
        puts "Rescued from Error. Failed to optimize post https://www.theteenmagazine.com/#{post.slug}"
      end
    end
  end

  # call with $rake content:optimize_paragraph_length\['https://www.theteenmagazine.com/test-pitch-test-pitch-test-pitch-test-pitch'\]
  task :optimize_paragraph_length, [:post_link] => :environment do |t, args|
    optimize_paragraph_length(args[:post_link])
  end

  # call with $rake content:add_links_case_sensitive\[rem beauty,'https://www.theteenmagazine.com/r-e-m-beauty-the-universe-of-ariana-grande'\]
  task :add_links_case_sensitive, [:key_phrase, :link] => :environment do |t, args|
    @slug = args[:link].split("https://www.theteenmagazine.com/")[1]
    # get all posts with key phrase and exclude post with passed in link; also exclude posts already with link
    posts = Post.published.where("content LIKE ?", "%#{args[:key_phrase]}%").where.not("slug LIKE ?", "%#{@slug}%").where.not("content LIKE ?", "%#{@slug}%")
    posts.each do |post|
      begin
        post.content = post.content.sub!(args[:key_phrase], "<a href='#{args[:link]}'>#{args[:key_phrase]}</a>")
        post.save(:validate => false)
        puts "Added link to https://www.theteenmagazine.com/#{post.slug}"
      rescue StandardError
        puts "Failed to add link to https://www.theteenmagazine.com/#{post.slug}"
      end
    end
    puts "To undo run: heroku run rake content:undo_link_building\\['#{args[:key_phrase]}','#{args[:link]}'\\]"
  end

  task :undo_link_building, [:key_phrase, :link] => :environment do |t, args|
    posts = Post.published.where("content LIKE ?", "%<a href='#{args[:link]}'>#{args[:key_phrase]}</a>%")
    posts.each do |post|
      begin
        post.content = post.content.sub!("<a href='#{args[:link]}'>#{args[:key_phrase]}</a>", "#{args[:key_phrase]}")
        post.save(:validate => false)
        puts "Removed link from https://www.theteenmagazine.com/#{post.slug}"
      rescue StandardError
        puts "Failed to remove link to https://www.theteenmagazine.com/#{post.slug}"
      end
    end
  end

  def optimize_paragraph_length(post_link)
    @slug = post_link.split("https://www.theteenmagazine.com/")[1]
    @post = Post.find(@slug)
    @post_content_length = @post.content.length
    @paragraphs = @post.content.scan(/<p(.*?)<\/p>/m)
    @paragraphs.each_with_index do |paragraph, index|
      if !paragraph[0].nil?
        # remove all links from paragraph
        @cleaned_paragraph = paragraph[0].gsub(/(http|ftp|https):\/\/([\w_-]+(?:(?:\.[\w_-]+)+))([\w.,@?^=%&:\/~+#-]*[\w@?^=%&\/~+#-])/, "")
        @sentences = @cleaned_paragraph.scan(/[^.!?]+[.!?](?=\s+[A-Z]|$|\s*<)/)
        # add break after every 3rd sentence for all paragraphs over 5 sentences long
        if @sentences.count >= 5
          @add_break_after = @sentences[2]
          if @post.content.include? @add_break_after
            @post.content = @post.content.sub(@add_break_after, "#{@add_break_after}</p><p>")
            puts "added paragraph break after the sentence: #{@add_break_after.truncate(60)}"
            # add new paragraph to paragraph array to optimize its length
            @paragraphs.push([@sentences.slice(3, @sentences.count).join(" ")])
          end
        # add break for all paragraphs over 500 chars
        elsif (@sentences.count >= 3) && (@sentences.join(" ").length > 600)
            @add_break_after = @sentences[1]
            if @post.content.include? @add_break_after
              @post.content = @post.content.sub(@add_break_after, "#{@add_break_after}</p><p>")
              puts "added paragraph break after the sentence: #{@add_break_after.truncate(60)}"
              # add new paragraph to paragraph array to optimize its length
              @paragraphs.push([@sentences.slice(2, @sentences.count).join(" ")])
            end
        end
      end
    end
    if @post.content.present? && (@post.content.length >= @post_content_length)
      @post.save(:validate => false)
      puts "Finished optimizing post https://www.theteenmagazine.com/#{@post.slug}"
    else
      puts "Failed to optimize post https://www.theteenmagazine.com/#{@post.slug}"
    end
  end
end
