require 'date'
namespace :trending do
    task calculate_trending: :environment do
        Post.published.each do |post|
            begin
                days = (Date.today - post.publish_at.to_date).to_i
                score = post.post_impressions * (0.96 ** days)
                post.update_attribute(:trending_score, score)
                puts "post #{post.id} given score #{score} (published #{days} ago, #{post.post_impressions} impressions)"
            rescue StandardError
                puts "Failed to calculate for post #{post.slug}"
            end
        end
    end
end