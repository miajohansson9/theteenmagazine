module NewslettersHelper
  def is_blocked(newsletter)
    # current user is sending newsletter
    @admin_lists = ["All Writers", "All Readers"]
    if current_user.present? && !current_user.admin? && (@admin_lists.include? @newsletter.audience)
      # user cannot send newsletter to this audience!
      return true
    end
    return false
  end

  def send_editor_picks(newsletter, new_thread = true)
    @newsletter = newsletter
    @posts = []
    @editor_quotes = []
    @featured_all = @newsletter.featured_posts.split("https://www.theteenmagazine.com/").drop(1)
    @featured_all.each_with_index do |featured, index|
      featured_arr = featured.split(" ")
      slug = featured_arr[0]
      editor_message = featured_arr.drop(1).join(" ")
      @editor_quotes[index] = editor_message
      @posts[index] = Post.find_by(slug: slug.strip)
    end
    if @posts.count.eql? 0
      redirect_to newsletters_path, notice: "Something went wrong"
      return
    end
    if new_thread
      if is_blocked(@newsletter)
        Sentry.capture_message("#{current_user.full_name} tried to send to audience #{@newsletter.audience}!")
        return
      else
        Thread.new do
          send_editor_picks_to_audience(@newsletter)
        end
      end
    else
      # newsletter is sent through task
      send_editor_picks_to_audience(@newsletter)
    end
  end

  def send_editor_picks_to_audience(newsletter)
    @newsletter = newsletter
    if @newsletter.audience.eql? "All Writers"
      send_editor_picks_helper(@newsletter, Subscriber.writer)
    elsif @newsletter.audience.eql? "Only Editors"
      send_editor_picks_helper(@newsletter, Subscriber.editor)
    elsif @newsletter.audience.eql? "Only Interviewers"
      send_editor_picks_helper(@newsletter, Subscriber.interviewer)
    elsif @newsletter.audience.eql? "All Readers"
      send_editor_picks_helper(@newsletter, Subscriber.where(subscribed_to_reader_newsletter: [true, nil]))
      if @newsletter.subject.include? "TTM TRENDING"
        @posts.each do |post|
          ApplicationMailer.featured_in_trending(post.user, post).deliver
        end
      elsif (@newsletter.subject.include? "EDITOR PICKS")
        @posts.each do |post|
          ApplicationMailer.featured_in_newsletter(post.user, post).deliver
        end
      end
    elsif @newsletter.audience.include? "Writers in"
      # is one of the categories
      @category_name = @newsletter.audience.split("Writers in ")[1]
      @category = Category.find_by("lower(name) = ?", @category_name.downcase)
      send_editor_picks_helper(@newsletter, @category.subscribers)
    end
  end

  def send_announcement(newsletter, new_thread = true)
    @newsletter = newsletter
    if new_thread
      if is_blocked(@newsletter)
        Sentry.capture_message("#{current_user.full_name} tried to send to audience #{@newsletter.audience}!")
        return
      else
        Thread.new do
          send_announcement_to_audience(@newsletter)
        end
      end
    else
      send_announcement_to_audience(@newsletter)
    end
  end

  def send_announcement_to_audience(newsletter)
    if @newsletter.audience.eql? "All Writers"
      send_announcement_helper(@newsletter, Subscriber.writer)
    elsif @newsletter.audience.eql? "Only Editors"
      send_announcement_helper(@newsletter, Subscriber.editor)
    elsif @newsletter.audience.eql? "Only Interviewers"
      send_announcement_helper(@newsletter, Subscriber.interviewer)
    elsif @newsletter.audience.eql? "All Readers"
      send_announcement_helper(@newsletter, Subscriber.where(subscribed_to_reader_newsletter: [true, nil]))
    elsif @newsletter.audience.include? "Writers in"
      # is one of the categories
      @category_name = @newsletter.audience.split("Writers in ")[1]
      @category = Category.find_by("lower(name) = ?", @category_name.downcase)
      send_announcement_helper(@newsletter, @category.subscribers)
    end
  end

  def send_editor_picks_helper(newsletter, audience)
    @newsletter = newsletter
    audience.each do |subscriber|
      begin
        ApplicationMailer.editor_picks(subscriber, @posts, @editor_quotes, @newsletter).deliver
        @newsletter.increment(:recipients, by = 1)
        @newsletter.save(:validate => false)
        subscriber.update_column("last_email_sent_at", Time.now)
        puts "Sent to reader #{subscriber.email}"
      rescue
        puts "Could not send to reader #{subscriber.email}"
      end
    end
  end

  def send_announcement_helper(newsletter, audience)
    @newsletter = newsletter
    audience.each do |subscriber|
      begin
        ApplicationMailer.custom_message_template(subscriber, @newsletter).deliver
        @newsletter.increment(:recipients, by = 1)
        @newsletter.save(:validate => false)
        subscriber.update_column("last_email_sent_at", Time.now)
      rescue
        puts "Could not send to reader #{subscriber.email}"
      end
    end
  end
end
