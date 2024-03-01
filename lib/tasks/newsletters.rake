require 'rake'
require "#{Rails.root}/app/helpers/newsletters_helper"
include NewslettersHelper

namespace :newsletters do
    task run_newsletter_tasks: :environment do
        if Date.today.monday?
            # send recents newsletter every monday
            @newsletter = recent
            send_to_audience(@newsletter)
        end

        if Date.today.wednesday?
            # send commenters newsletter every other week
            if Date.today.cweek.even?
                @newsletter = commenters
                send_to_audience(@newsletter)
            end
        end

        if Date.today.thursday?
            # send trending newsletter every thursday
            @newsletter = trending
            send_to_audience(@newsletter)
        end

        # create editor picks newsletter
        if Date.today.day.eql? 20
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

    def send_to_audience(newsletter)
        if Newsletter.where(audience: newsletter.audience).where(sent_at: (Time.now - 1.day)..Time.now).present?
            # newsletter sent to audience within one day
            puts "Do not send newsletters to the same audience within one day of each other"
            return
        end
        if newsletter.template.eql? "Announcement"
            newsletter.update_column(:sent_at, Time.now)
            newsletter.update_column(:recipients, 0)
            send_announcement(newsletter, false)
        elsif newsletter.template.eql? "Weekly Picks"
            if (newsletter.featured_posts.scan("theteenmagazine.com").count >= 6)
                newsletter.update_column(:sent_at, Time.now)
                newsletter.update_column(:recipients, 0)
                send_editor_picks(newsletter, false)
            end
        end
    end

    def commenters(weeks=2)
        @weeks = weeks.present? ? weeks.to_i : 2
        @start_date = Date.today - (7 * @weeks)
        @comments = Comment.where('created_at > ?', @start_date).where(is_review: [nil, false])
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
        return newsletter
        puts "Created commenters newsletter"
    end

    def trending(category=nil)
        if category.present?
            @category = Category.find(category)
            @posts = Post.published.trending.where(category_id: @category.id).limit(6)
        else
            @posts = Post.published.trending.limit(6)
        end
        @featured_posts = []
        @posts.each do |post|
            @featured_posts.push("https://www.theteenmagazine.com/#{post.slug}")
        end
        @header = @category.nil? ? "What's trending!" : "#{@category.name.titleize}: What's trending!"
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
        return newsletter
        puts "Created trending newsletter"
    end

    def recent(category=nil)
        if category.present?
            @category = Category.find(category)
            @posts = Post.where('publish_at > ?', Time.now - 1.week).where(category_id: @category.id).trending.limit(6)
        else
            @posts = Post.where('publish_at > ?', Time.now - 1.week).trending.limit(6)
        end
        @featured_posts = []
        @posts.each do |post|
            @featured_posts.push("https://www.theteenmagazine.com/#{post.slug}")
        end
        @header = @category.nil? ? "What's new!" : "#{@category.name.titleize}: What's new!"
        @name_prep = @category.nil? ? "on <a href='https://www.theteenmagazine.com?utm_source=newsletter&utm_medium=email&utm_campaign=editor+picks'>The Teen Magazine</a>" : "in <a href='https://www.theteenmagazine.com/categories/#{@category.slug}?utm_source=newsletter&utm_medium=email&utm_campaign=editor+picks'>#{@category.name}</a>"
        newsletter = Newsletter.new(
            subject: "#{@posts.first.title.truncate(90)} & more",
            header: @header,
            template: "Weekly Picks",
            audience: "All Readers",
            message: "<p style='font-size: 16px'>Below are the most recent articles published #{@name_prep}. If you haven&#39;t checked these out yet, we highly&nbsp;recommend that you do!</p><p style='font-size: 16px'>The Teen Magazine Editor Team&nbsp;&lt;3</p>",
            user_id: 1,
            featured_posts: @featured_posts.join(" ")
        )
        newsletter.save!
        return newsletter
        puts "Created recents newsletter"
    end

    def editor_picks
        @month = (Date.today - 19.days).in_time_zone&.strftime("%B")
        @next_month = Date.today.in_time_zone&.strftime("%B")
        @num_total_articles = Post.published.where(publish_at: ((Date.today - 25.days).beginning_of_month..(Date.today - 25.days).end_of_month)).count
        newsletter = Newsletter.new(
            subject: "#{@month.upcase} 2023 EDITOR PICKS ANNOUNCED!",
            header: "Editor Picks from #{@month}! 🎉",
            template: "Weekly Picks",
            audience: "All Readers",
            message: "<p style='font-size: 16px'>#{@month} was an incredible month for our team of student writers who published&nbsp; #{@num_total_articles} articles!&nbsp;After careful review, our editors have chosen 6 articles that stood out and deserve a special shoutout.</p> <p style='font-size: 16px'>To the writers whose articles were included, congratulations!&nbsp;And to our email subscribers, we highly recommend that you check out these articles.&nbsp;🤩</p><p style='font-size: 16px'>Stay tuned for our editors&#39; top picks from #{@next_month} in our next newsletter.</p>",
            user_id: 1,
            subheader: "#{@month} 1 to #{@month} #{(Date.today - 25.days).end_of_month.day}"
        )
        newsletter.save!
        puts "Created editor picks newsletter"
    end
end