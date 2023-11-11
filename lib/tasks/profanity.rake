
namespace :profanity do
    task :check_for_bad_words_in_posts, [:replace] => :environment do |t, args|
        bad_words = YAML.load_file(Rails.root.join('config', 'small_blacklist.yml'))
        Post.where('publish_at is NOT NULL OR publish_at < ?', Time.now).find_each do |post|
            content = post.content.to_s.downcase
            bad_words_pattern = Regexp.union(bad_words.map { |word| /\b#{Regexp.escape(word)}\b/i })
            found_bad_words = content.scan(bad_words_pattern)
            if found_bad_words.any?
                puts "Post #{post.id} contains bad words: #{found_bad_words.join(', ')}"
                # if (args[:update_profanity_score] == 'true')
                #     post.profanity_score = found_bad_words.size
                #     post.save
                #     puts "updating profanity score to: #{post.profanity_score}"
                # end
                if (args[:replace] == 'true')
                    bad_words_pattern = Regexp.union(bad_words.map { |word| /\b#{Regexp.escape(word)}\b/i })
                    # Replace bad words with a placeholder (e.g., '[censored]')
                    censored_content = content.gsub(bad_words_pattern, '[censored]')
                    puts 'Censored content'
                    post.content = censored_content
                    post.save
                end
            end
        end
    end

    task :check_for_bad_words_in_comments, [:delete] => :environment do |t, args|
        bad_words = YAML.load_file(Rails.root.join('config', 'blacklist.yml'))
        Comment.find_each do |comment|
            if comment.is_public?
                content = "#{comment.text.to_s.downcase} #{comment.full_name}" 
                bad_words_pattern = Regexp.union(bad_words.map { |word| /\b#{Regexp.escape(word)}\b/i })
                found_bad_words = content.scan(bad_words_pattern)
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
end