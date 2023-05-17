namespace :content do
  # call with $rake content:optimize_paragraph_length\['https://www.theteenmagazine.com/test-pitch-test-pitch-test-pitch-test-pitch'\]
  task :optimize_paragraph_length, [:post_link] => :environment do |t, args|
    @slug = args[:post_link].split("https://www.theteenmagazine.com/")[1]
    @post = Post.find(@slug)
    begin
      @paragraphs = @post.content.split("</p>")
      @paragraphs.each_with_index do |paragraph, index|
        # only include <p> tags in sentence count
        paragraph_cleaned = paragraph.split("<p").count > 1 ? paragraph.split("<p")[1] : paragraph
        # get number of sentences
        @sentences = paragraph_cleaned.split(/(?<=[?.!])/)
        # add break after every 3rd sentence for all paragraphs over 5 sentences long
        if @sentences.count >= 5
          @add_break_after = @sentences[2]
          @post.content = @post.content.sub!(@add_break_after, "#{@add_break_after}</p><p>")
          puts "added paragraph break after the sentence: #{@add_break_after}"
          # add new paragraph to paragraph array to optimize its length
          @paragraphs.push(@sentences.slice(3, @sentences.count - 1).join(""))
        end
      end
      @post.save(:validate => false)
      puts "Finished optimizing post https://www.theteenmagazine.com/#{@post.slug}"
    rescue StandardError
      puts "Failed to optimize https://www.theteenmagazine.com/#{@post.slug}"
    end
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
end
