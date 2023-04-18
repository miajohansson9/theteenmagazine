require 'date'
namespace :newsletters do
    task commenters_newsletter: :environment do
        @comments = Comment.published.where(created_at: (Time.now - 1.week)..Time.now)
        @commenters = []
        User.writer.where(last_sign_in_at: (Time.now - 1.month)..Time.now).each do |user|
            @user_comments = user.comments.published.where(created_at: (Time.now - 1.week)..Time.now)
            if !@user_comments.nil? && @user_comments.count >= 5
                @commenters[@user_comments.count - 5] = "<address style='text-align: center;'><a href='https://www.theteenmagazine.com/writers/" + user.slug + "'>" + user.full_name + "</a>, " + "#{@user_comments.count}" + " comments</address>"
            end
        end
        @commenters = @commenters.reverse.join(" ")
        newsletter = Newsletter.new(
            subject: "TTM UPDATE: Comments",
            header: "Thank you to the writers who have been commenting!",
            message: "<p>There have been #{@comments.count} comments in just the past 7 days!!<strong>&nbsp;</strong>🥳🤩</p><p>Thank you to all the writers who commented on so many articles.&nbsp;I appreciate your support, and I know it was fun for the writers who got comments on their articles.</p><p>Here are the writers who commented the most on published articles in the past week. </p>" + @commenters + "<p>Thank you, and please continue supporting and uplifting each other! 😍</p>",
            template: "Announcement",
            audience: "All Writers",
            user_id: 1,
            action_button: "Comment on Recent Articles, https://www.theteenmagazine.com/"
        )
        newsletter.save!
    end
end