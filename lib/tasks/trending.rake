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

    task calculate_ranks: :environment do
        Category.active.each do |category|
            Post.published.where(category_id: category.id).trending.limit(100).each_with_index do |post, index|
                begin
                    post.update_column(:rank, index + 1)
                    puts "updated post #{post.slug} with rank #{index + 1} in category #{category.name}"
                rescue
                    puts "failed to update post #{post.slug} with rank #{index + 1} in category #{category.name}"
                end
            end
        end
    end
end