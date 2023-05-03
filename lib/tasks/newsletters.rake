require 'rake'
namespace :newsletters do
    task run_newsletter_tasks: :environment do
        if Date.today.sunday?
            recent
        end

        if Date.today.sunday? && ((Date.today.cweek % 3).eql? 3)
            commenters(3)
        end

        if Date.today.wednesday?
            @categories = ['mental-health-self-love','opinion','student-life','beauty-style','interviews','pop-culture','books-writing']
            if Date.today.cweek.odd?
                trending
            else
                trending(@categories[Date.today.cweek % 7])
            end
        end

        if Date.today.day.eql? 1
            editor_picks
        end
    end

    task :commenters, [:weeks] => :environment do |t, args|
        commenters(args[:weeks])
    end

    task :trending, [:category] => :environment do |t, args|
        trending(args[:category])
    end

    task :recent, [:category] => :environment do |t, args|
        recent(args[:category])
    end

    task editor_picks: :environment do
        editor_picks
    end

    def commenters(weeks)
        @weeks = weeks.present? ? weeks.to_i : 2
        @start_date = Date.today - (7 * @weeks)
        @comments = Comment.where('created_at > ?', @start_date)
        @commenters = [[]]
        @writers = [[]]
        User.writer.where(last_sign_in_at: (Time.now - 1.month)..Time.now).each do |user|
            @user_comments = @comments.where(user_id: user.id)
            if !@user_comments.nil? && @user_comments.count >= 3
                if @commenters[@user_comments.count - 3].nil?
                    @writers[@user_comments.count - 3] = [user.first_name]
                    @commenters[@user_comments.count - 3] = ["<address style='text-align: center;'><a href='https://www.theteenmagazine.com/writers/" + user.slug + "'>" + user.full_name + "</a>, " + "#{@user_comments.count}" + " comments</address>"]
                else
                    @writers[@user_comments.count - 3] = @writers[@user_comments.count - 3].push(user.first_name)
                    @commenters[@user_comments.count - 3] = @commenters[@user_comments.count - 3].push("<address style='text-align: center;'><a href='https://www.theteenmagazine.com/writers/" + user.slug + "'>" + user.full_name + "</a>, " + "#{@user_comments.count}" + " comments</address>")
                end
            end
        end
        @commenters[-1].each_with_index do |comment, index|
            @commenters[-1][index] = "<strong>" + comment + "</strong>"
        end
        @commenters.each_with_index do |comment, index|
            if comment.present?
                @commenters[index] = comment.join(' ')
            end
        end
        @writers.each_with_index do |writer, index|
            if writer.present?
                @writers[index] = writer.join(' ')
            end
        end
        @commenters = @commenters.reverse.first(12).join(' ')
        @writers = @writers.delete_if(&:blank?).reverse.first(4).join(', ')
        newsletter = Newsletter.new(
            subject: "TTM UPDATE: Thank you #{@writers} & more!",
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

    def trending(category)
        if category.present?
            @category = Category.find(category)
            @posts = Post.published.trending.where(category_id: @category.id).limit(8)
        else
            @posts = Post.published.trending.limit(8)
        end
        @featured_posts = []
        @posts.each do |post|
            @featured_posts.push("https://www.theteenmagazine.com/#{post.slug}")
        end
        @header = @category.nil? ? "What's trending!" : "#{@category.name.capitalize}: What's trending!"
        @name_prep = @category.nil? ? "on <a href='https://www.theteenmagazine.com?utm_source=newsletter&utm_medium=email&utm_campaign=editor+picks'>The Teen Magazine</a>" : "in <a href='https://www.theteenmagazine.com/categories/#{@category.slug}?utm_source=newsletter&utm_medium=email&utm_campaign=editor+picks'>#{@category.name}</a>"
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

    def recent(category)
        if category.present?
            @category = Category.find(category)
            @posts = Post.where('publish_at > ?', Time.now - 1.week).where(category_id: @category.id).trending.limit(8)
        else
            @posts = Post.where('publish_at > ?', Time.now - 1.week).trending.limit(8)
        end
        @featured_posts = []
        @posts.each do |post|
            @featured_posts.push("https://www.theteenmagazine.com/#{post.slug}")
        end
        @header = @category.nil? ? "What's new!" : "#{@category.name.capitalize}: What's new!"
        @name_prep = @category.nil? ? "on <a href='https://www.theteenmagazine.com?utm_source=newsletter&utm_medium=email&utm_campaign=editor+picks'>The Teen Magazine</a>" : "in <a href='https://www.theteenmagazine.com/categories/#{@category.slug}?utm_source=newsletter&utm_medium=email&utm_campaign=editor+picks'>#{@category.name}</a>"
        newsletter = Newsletter.new(
            subject: "RECENT ON TTM 💬: #{@posts.first.title.truncate(60)} & more",
            header: @header,
            template: "Weekly Picks",
            audience: "All Readers",
            message: "<p style='font-size: 16px'>Below are the most recent articles published #{@name_prep}. If you haven&#39;t checked these out yet, we highly&nbsp;recommend that you do!</p><p style='font-size: 16px'>The Teen Magazine Editor Team&nbsp;&lt;3</p>",
            user_id: 1,
            featured_posts: @featured_posts.join(" ")
        )
        newsletter.save!
        puts "Created recents newsletter"
    end

    def editor_picks
        @month = (Date.today - 25.days).in_time_zone&.strftime("%B")
        @next_month = Date.today.in_time_zone&.strftime("%B")
        @num_total_articles = Post.published.where(publish_at: ((Date.today - 25.days).beginning_of_month..(Date.today - 25.days).end_of_month)).count
        newsletter = Newsletter.new(
            subject: "#{@month} Editor Picks are Here!",
            header: "Editor Picks from #{@month}! 🎉",
            template: "Weekly Picks",
            audience: "All Readers",
            message: "<p>#{@month} was an incredible month for our team of student writers who published&nbsp; #{@num_total_articles} articles!&nbsp;After careful review, our editors have chosen 6 articles that stood out and deserve a special shoutout.</p> <p>To the writers whose articles were included, congratulations!&nbsp;And to our email subscribers, we highly recommend that you check out these articles.&nbsp;🤩</p><p>Stay tuned for our editors&#39; top picks from #{@next_month} in our next newsletter.</p>",
            user_id: 1,
            subheader: "#{@month} 1 to #{@month} #{(Date.today - 25.days).end_of_month.day}"
        )
        newsletter.save!
        puts "Created editor picks newsletter"
    end
end