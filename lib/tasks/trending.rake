require 'date'
namespace :trending do
    task :calculate_trending, [:gravity] => :environment do |t, args|
        G = args[:gravity].present? ? args[:gravity].to_f : 1.8
        Post.published.each do |post|
            begin
                @hours = ((Time.now - post.publish_at) / 1.hour).round
                @points = post.post_impressions.to_f
                score = (@points / ((@hours+24.0)**G)) * 10000.0
                post.update_attribute(:trending_score, score)
                puts "post #{post.id} given score #{score} (published #{@hours} hours ago, #{@points} impressions)"
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