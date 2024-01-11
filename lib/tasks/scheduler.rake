require "date"

task run_weekly_tasks: :environment do
  Rake::Task["sitemap:refresh"].invoke if (Date.today.monday?)

  if (Date.today.friday?)
    Post.draft.each do |post|
      if post.sharing
        if post.shared_at.nil?
          post.update("sharing" => false)
        elsif post.shared_at < Time.now - 1.month
          post.update("shared_at" => nil, "sharing" => false)
        end
      end
    end
  end
end

task run_nightly_tasks: :environment do
  # update trending ranks
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

  ## Send warning emails if editor is not on track to complete assignments
  if (Date.today.day.eql? 18)
    @reviews_requirement =
      Integer(
        Constant
          .find_by(name: "# of monthly reviews editors need to complete")
          .try(:value) || "0"
      )
    @pitches_requirement =
      Integer(
        Constant
          .find_by(name: "# of monthly pitches editors need to complete")
          .try(:value) || "0"
      )
    @comments_requirement =
      Integer(
        Constant
          .find_by(name: "# of monthly comments editors need to complete")
          .try(:value) || "0"
      )
    User.editor.each do |editor|
      if !(editor.is_manager?)
        @editor_pitches_cnt =
          editor
            .pitches
            .where("created_at > ?", Date.today.beginning_of_month)
            .count
        @editor_reviews_cnt =
          Review
            .where(editor_id: editor.id)
            .where("updated_at > ?", Date.today.beginning_of_month)
            .count
        @editor_comments_cnt = editor.comments.where("created_at > ?", Date.today.beginning_of_month).count
        @is_not_on_track =
          (@editor_pitches_cnt + @editor_reviews_cnt + @editor_comments_cnt <
          (@reviews_requirement + @pitches_requirement + @comments_requirement) / 2) && (editor.created_at < (Time.now - 30.days))
        if @is_not_on_track
          # check if missed editor deadline for two months ago
          # ie. today is May 1st; I want to check if missed deadline in April too
          if (editor.missed_editor_deadline.try(:year) === (Time.now - 20.days).year) &&
            (editor.missed_editor_deadline.try(:month) === (Time.now - 20.days).month) &&
            !(editor.skip_assignment)
            ApplicationMailer.editor_warning_deadline_2(
              editor,
              @reviews_requirement,
              @pitches_requirement,
              @comments_requirement,
              @editor_pitches_cnt,
              @editor_reviews_cnt,
              @editor_comments_cnt
            ).deliver
          else
            ApplicationMailer.editor_warning_deadline_1(
              editor,
              @reviews_requirement,
              @pitches_requirement,
              @comments_requirement,
              @editor_pitches_cnt,
              @editor_reviews_cnt,
              @editor_comments_cnt
            ).deliver
          end
        end
      end
    end
  end

  if (Date.today.day.eql? 1)
    @reviews_requirement =
      Integer(
        Constant
          .find_by(name: "# of monthly reviews editors need to complete")
          .try(:value) || "0"
      )
    @pitches_requirement =
      Integer(
        Constant
          .find_by(name: "# of monthly pitches editors need to complete")
          .try(:value) || "0"
      )
    @comments_requirement =
      Integer(
        Constant
          .find_by(name: "# of monthly comments editors need to complete")
          .try(:value) || "0"
      )
    User.editor.each do |editor|
      @editor_pitches_cnt =
        editor
          .pitches
          .where("created_at > ?", Date.yesterday.beginning_of_month)
          .count
      @editor_reviews_cnt =
        Review
          .where(editor_id: editor.id)
          .where("updated_at > ?", Date.yesterday.beginning_of_month)
          .count
      @editor_comments_cnt =
        editor
          .comments
          .where("created_at > ?", Date.yesterday.beginning_of_month)
          .count
      @missed_deadline =
        ((@editor_pitches_cnt < @pitches_requirement) ||
         (@editor_comments_cnt < @comments_requirement) ||
         (@editor_reviews_cnt < @reviews_requirement)) && (editor.created_at < (Time.now - 31.days))
      if @missed_deadline && !@editor.is_manager? && !editor.skip_assignment
        # check if missed editor deadline for two months ago
        # ie. today is May 1st; I want to check if missed deadline in March too
        if (editor.missed_editor_deadline.try(:year) === (Time.now - 32.days).year) &&
           (editor.missed_editor_deadline.try(:month) === (Time.now - 32.days).month)
          ApplicationMailer.removed_editor_from_team(editor).deliver
          editor.update_attribute("editor", false)
          editor.update_attribute("became_an_editor", nil)
          editor.update_attribute("completed_editor_onboarding", nil)
        else
          ApplicationMailer.editor_missed_deadline_1(
            editor,
            @reviews_requirement,
            @pitches_requirement,
            @comments_requirement,
            @editor_pitches_cnt,
            @editor_reviews_cnt,
            @editor_comments_cnt
          ).deliver
          # update missed assignment for previous month
          editor.update_attribute("missed_editor_deadline", Time.now - 1.day)
        end
      end
    end
  end

  if (Date.today.day.eql? 1)
    User.editor.each do |editor|
      ApplicationMailer.remind_editors_of_assigments(editor).deliver
    end
    @editors_with_passes = User.where(skip_assignment: true)
    @editors_with_passes.each do |editor|
      editor.update_column("skip_assignment", false)
    end
  end

  if Date.today.saturday?
    @categories = Category.active
    @category_scores = Hash.new
    puts ""
    @categories.each do |category|
      @pageviews = 0
      @comments = 0
      @posts = category.posts.published.where(publish_at: (Time.now - 1.week)..Time.now)
      @articles = @posts.count
      @posts.each do |post|
        @comments = @comments + post.comments.published.count
        @pageviews = @pageviews + post.post_impressions
      end
      @score = @comments * 2 + @pageviews + @articles * 3
      @category_scores[category.id] = @score
      puts "#{category.name}"
      puts "[#{@score}] Articles: #{@articles}, Pageviews: #{@pageviews}, Comments: #{@comments}"
      puts ""
    end
    # Sort the categories by their scores in descending order
    sorted_categories = @category_scores.sort_by { |_id, score| -score }

    # Print each category with its rank and score
    sorted_categories.each_with_index do |(category_id, score), index|
      category = Category.find(category_id)
      puts "Rank #{index + 1}: Category #{category.name}"
      category.update_column("rank", index + 1)
    end
  end

  if (Date.today.day.eql? Date.today.end_of_month.day)
    # Update monthly extensions for active writers
    User.active.each do |user|
      begin
        user.update("extensions" => user.extensions + 1)
      rescue StandardError
        next
      end
    end
  end

  # Writer is close to article deadline or missed it
  User.all.each do |user|
    @posts = []
    @pitches = Pitch.where(claimed_id: user.id).where.not(deadline: nil)
    @pitches.each do |pitch|
      @post = pitch.posts.draft.find_by(user_id: pitch.claimed_id)
      if @post.present? && @post.try(:deadline_at)&.present?
        if @post.deadline_at < Time.now
          @post.reviews.each { |review| review.destroy }
          @post.title = "#{@post.title} (locked)"
          @post.save
          @post.pitch.update("claimed_id" => nil)
          @post.pitch.update("archive" => !@post.pitch.user.editor)
          @slug =
            FriendlyId::Slug.where(
              slug: @post.pitch.slug,
              sluggable_type: "Post",
            )
          @slug&.destroy_all
          ApplicationMailer.article_deadline_passed(user, @post).deliver
        elsif @post.deadline_at < (Time.now + 1.days)
          @posts << @post
        elsif ((Time.now + 3.days)..(Time.now + 4.days)).include? @post
                                                                    .deadline_at
          @posts << @post
        elsif ((Time.now + 6.days)..(Time.now + 7.days)).include? @post
                                                                    .deadline_at
          @posts << @post
        end
      end
    end
    if @posts.present?
      ApplicationMailer.article_deadline_warning(user, @posts).deliver
    end
  end

  # If an editor did not complete their review within 48 hours of claiming it, unclaim the review and send an email to the editor
  # Notify opted in editors of the new review
  @overdue_reviews =
    Review
      .where.not(editor_id: nil)
      .where(active: true, status: "In Review")
      .where("editor_claimed_review_at < ?", Time.now - 48.hours)
  @overdue_reviews.each do |review|
    @editor = User.find_by(id: review.editor_id)
    if @editor.present? && review.post.present?
      ApplicationMailer.editor_missed_review_deadline(@editor, review.post).deliver
      review.editor_id = nil
      review.editor_claimed_review_at = nil
      review.status = "Ready for Review"
      review.save(:validate => false)
    end
  end

  # Notify writers of new badge earned
  if Date.today.day.eql? 16
    User
      .includes(:posts)
      .where.not(posts: { id: nil })
      .each do |user|
      @user_posts_approved_records =
        Post
          .where("collaboration like ?", "%#{user.email}%")
          .or(Post.where(user_id: user.id))
          .published
          .by_published_date
      @pageviews = @user_posts_approved_records.sum(&:post_impressions)

      # if you want to change a badge color, you must update all the already created badges
      # to match the new color
      @levels = [
        ["1 million+", "#D31E26", 1_000_000],
        ["800k+", "#C50285", 800_000],
        ["500k+", "#00215B", 500_000],
        ["300k+", "#6A198E", 300_000],
        ["100k+", "#a88beb", 100_000],
        ["50k+", "#a88beb", 50_000],
        ["20k+", "#00acee", 20_000],
        ["10k+", "#EF265F", 10_000],
        ["5,000+", "#4ABEB6", 5000],
        ["1,000+", "#4ABEB6", 1000],
      ]
      @levels.each_with_index do |level, index|
        if user.badges.where(level: level[0]).present?
          break
        elsif (@pageviews >= level[2]) &&
              (user.badges.where(level: level[0]).count.eql? 0)
          @badge =
            user.badges.build(
              level: level[0],
              kind: "pageviews",
              color: level[1],
            )
          ApplicationMailer.new_badge_earned(user, @badge).deliver
          break
        end
      end
    end
  end
end
