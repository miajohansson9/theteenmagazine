namespace :linkbuilding do
    # call with $rake linkbuilding:add_links_case_sensitive\[rem beauty,'https://www.theteenmagazine.com/r-e-m-beauty-the-universe-of-ariana-grande'\]
    task :add_links_case_sensitive, [:key_phrase, :link] => :environment do |t, args|
        @slug = args[:link].split("https://www.theteenmagazine.com/")[1]
        # get all posts with key phrase and exclude post with passed in link
        posts = Post.published.where("content LIKE ?", "%#{args[:key_phrase]}%").where.not("slug LIKE ?", "%#{@slug}%")
        posts.each do |post|
            begin
                post.content = post.content.sub!(args[:key_phrase], "<a href='#{args[:link]}'>#{args[:key_phrase]}</a>")
                post.save(:validate => true)
                puts "Added link to https://www.theteenmagazine.com/#{post.slug}"
            rescue StandardError
                puts "Failed to add link to https://www.theteenmagazine.com/#{post.slug}"
            end
        end
    end
end