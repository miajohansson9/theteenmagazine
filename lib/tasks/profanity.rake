
namespace :profanity do
    task :check_for_bad_words_in_posts, [:update_profanity_score] => :environment do |t, args|
        bad_words = YAML.load_file(Rails.root.join('config', 'blacklist.yml'))
        Post.find_each do |post|
            content = post.content.to_s.downcase
            found_bad_words = bad_words.select { |word| /\b#{Regexp.escape(word)}\b/i.match?(content) }
            if found_bad_words.any?
                puts "Post #{post.id} contains bad words: #{found_bad_words.join(', ')}"
                if (args[:update_profanity_score])
                    post.profanity_score = found_bad_words.length
                    post.save
                    puts "updating profanity score to: #{post.profanity_score}"
                end
            end
        end
    end

    task :check_for_bad_words_in_comments, [:delete] => :environment do |t, args|
        bad_words = YAML.load_file(Rails.root.join('config', 'blacklist.yml'))
        Comment.find_each do |comment|
            content = "#{comment.text.to_s.downcase} #{comment.full_name}" 
            found_bad_words = bad_words.select { |word| /\b#{Regexp.escape(word)}\b/i.match?(content) }
            if found_bad_words.any?
                puts "Comment on #{comment.post_id} contains bad words: #{found_bad_words.join(', ')}"
                if (args[:delete])
                    comment.destroy
                    puts "Deleted comment"
                end
            end
        end
    end
end