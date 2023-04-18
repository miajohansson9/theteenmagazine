require 'rake'
namespace :newsletters do
    task :commenters, [:weeks] => :environment do |t, args|
        @weeks = args[:weeks].present? ? args[:weeks].to_i : 2
        @start_date = Date.today - (7 * @weeks)
        @comments = Comment.where(created_at: (@start_date.. Time.now))
        @commenters = []
        User.writer.where(last_sign_in_at: (Time.now - 1.month)..Time.now).each do |user|
            @user_comments = user.comments.published.where(created_at: (Time.now - 3.weeks)..Time.now)
            if !@user_comments.nil? && @user_comments.count >= 5
                @commenters[@user_comments.count - 5] = "<address style='text-align: center;'><a href='https://www.theteenmagazine.com/writers/" + user.slug + "'>" + user.full_name + "</a>, " + "#{@user_comments.count}" + " comments</address>"
            end
        end
        @commenters = @commenters.reverse.join(" ")
        newsletter = Newsletter.new(
            subject: "TTM UPDATE: Comments",
            header: "Thank you to the writers who have been commenting!",
            message: "<p>There have been #{@comments.count} comments in the past #{@weeks * 7} days!!<strong>&nbsp;</strong>🥳🤩</p><p>Thank you to all the writers who commented on so many articles.&nbsp;I appreciate your support, and I know it was fun for the writers who got comments on their articles.</p><p>Here are the writers who commented on the most articles in the past #{@weeks * 7} days. </p>" + @commenters + "<p>Thank you, and please continue supporting and uplifting each other! 😍</p>",
            template: "Announcement",
            audience: "All Writers",
            user_id: 1,
            action_button: "Comment on Recent Articles, https://www.theteenmagazine.com/"
        )
        newsletter.save!
        puts "Created commenters newsletter"
    end

    task :trending, [:category] => :environment do |t, args|
        if args[:category].present?
            @category = Category.find(args[:category])
            @posts = Post.published.trending.where(category_id: @category.id).limit(8)
        else
            @posts = Post.published.trending.limit(8)
        end
        @featured_posts = []
        @posts.each do |post|
            @featured_posts.push("https://www.theteenmagazine.com/#{post.slug}")
        end
        @header = @category.nil? ? "What's trending!" : "#{@category.name.capitalize}: What's trending!"
        @name_prep = @category.nil? ? "on <a href='https://www.theteenmagazine.com'>The Teen Magazine</a>" : "in <a href='https://www.theteenmagazine.com/#{@category.slug}'>#{@category.name}</a>"
        newsletter = Newsletter.new(
            subject: "TTM TRENDING 🔥: #{@posts.first.title.truncate(60)} & more",
            header: @header,
            template: "Weekly Picks",
            audience: "All Readers",
            message: "<p style='font-size: 16px'>Below is a list of the top trending articles #{@name_prep} this week. If you haven&#39;t read these yet, we highly&nbsp;recommend that you do!</p><p style='font-size: 16px'>The Teen Magazine Editor Team&nbsp;&lt;3</p>",
            user_id: 1,
            featured_posts: @featured_posts.join(" ")
        )
        newsletter.save!
        puts "Created trending newsletter"
    end
end