class NewslettersController < ApplicationController
  before_action :authenticate_user!
  before_action :is_admin?
  before_action :find_newsletter, except: %i[index new create]

  def index
    @pagy, @newsletters =
    pagy(
      Newsletter.order("created_at desc"),
      page: params[:page],
      items: 20,
    )
  end

  def new
    @newsletter = current_user.newsletters.new
    # @newsletter =
    #   Newsletter.find_by(kind: nil) || current_user.newsletters.new
    # @newsletter.hero_image.attach(Newsletter.not_nil.last.try(:hero_image).blob)
    # @pagy, @posts =
    #   pagy(
    #     Post.published.where(newsletter_id: nil),
    #     page: params[:page],
    #     items: 20,
    #   )
    # @newsletter_posts = []
    # @disabled = true
  end

  def edit
    @posts = Post.published.where(newsletter_id: nil)
    @newsletter_posts = @newsletter.posts || []
    @newsletters_to_send_before_cnt =
      Newsletter
        .where(sent_at: nil)
        .where("created_at < ?", @newsletter.created_at)
        .count
    @disabled = @newsletter_posts.count < 5
  end

  def create
    @newsletter = current_user.newsletters.build(newsletter_params)
    if newsletter_params[:hero_image].present?
      @newsletter.hero_image.attach(newsletter_params[:hero_image])
    end
    if @newsletter.save
      redirect_to @newsletter
    else
      render "new", notice: "Something went wrong"
    end
  end

  def destroy
    @newsletter.posts.map { |p| p.update_column(:newsletter_id, nil) }
    if @newsletter.destroy
      redirect_to newsletters_path, notice: "Your newsletter was deleted."
    end
  end

  def update
    # if newsletter_params[:hero_image].present?
    #   @newsletter.hero_image.attach(newsletter_params[:hero_image])
    # end
    if @newsletter.update newsletter_params
      redirect_to @newsletter, notice: "Your changes were saved."
    else
      render "new"
    end
  end

  #only allow admin can send/create newsletters
  def is_admin?
    if (current_user &&
        (current_user.admin? || current_user.has_newsletter_permissions))
      true
    else
      redirect_to current_user, notice: "You do not have access to this page."
    end
  end

  #show application to editor
  #form for creating a new user already filled out
  def show
    if @newsletter.action_button.present?
      @button = @newsletter.action_button.split(",")
      @button_text = @button[0]
      @button_link = (@button.length.eql? 2) ? @button[1].gsub(" ", "") : ""
    end
    if @newsletter.featured_posts.present?
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
    end
  end

  def send_test_newsletter
    @subscriber = Subscriber.find_by(user_id: params[:user_id])
    @newsletter = Newsletter.find(params[:id])
    if @newsletter.template.eql? "Weekly Picks"
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
      if ApplicationMailer.editor_picks(@subscriber, @posts, @editor_quotes, @newsletter).deliver
        redirect_to "/newsletters/#{params[:id]}", notice: "Test email sent to #{@subscriber.email}"
      else
        redirect_to "/newsletters/#{params[:id]}", notice: "Something went wrong"
      end
    elsif @newsletter.template.eql? "Announcement"
      if ApplicationMailer.custom_message_template(@subscriber, @newsletter).deliver
        redirect_to "/newsletters/#{params[:id]}", notice: "Test email sent to #{@subscriber.email}"
      else
        redirect_to "/newsletters/#{params[:id]}", notice: "Something went wrong"
      end
    end
  end

  def send_to_audience
    @newsletter.update_column(:sent_at, Time.now)
    @newsletter.update_column(:recipients, 0)
    if @newsletter.template.eql? "Announcement"
      send_announcement
    elsif @newsletter.template.eql? "Weekly Picks"
      send_editor_picks
    end
    redirect_to "/newsletters", notice: "Email is sending to #{@newsletter.audience}"
  end

  def send_editor_picks
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
    Thread.new do
      if @newsletter.audience.eql? "All Writers"
        send_editor_picks_helper(Subscriber.writer)
      elsif @newsletter.audience.eql? "Only Editors"
        send_editor_picks_helper(Subscriber.editor)
      elsif @newsletter.audience.eql? "Only Interviewers"
        send_editor_picks_helper(Subscriber.interviewer)
      elsif @newsletter.audience.eql? "All Readers"
        send_editor_picks_helper(Subscriber.where(subscribed_to_reader_newsletter: [true, nil]))
        if @newsletter.subject.include? "TTM TRENDING"
          @posts.each do |post|
            ApplicationMailer.featured_in_trending(post.user, post).deliver
          end
        else
          @posts.each do |post|
            ApplicationMailer.featured_in_newsletter(post.user, post).deliver
          end
        end
      end
    end
  end

  def send_editor_picks_helper(audience)
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

  def send_announcement
    Thread.new do
      if @newsletter.audience.eql? "All Writers"
        send_announcement_helper(Subscriber.writer)
      elsif @newsletter.audience.eql? "Only Editors"
        send_announcement_helper(Subscriber.editor)
      elsif @newsletter.audience.eql? "Only Interviewers"
        send_announcement_helper(Subscriber.interviewer)
      elsif @newsletter.audience.eql? "All Readers"
        send_announcement_helper(Subscriber.where(subscribed_to_reader_newsletter: [true, nil]))
      end
    end
  end

  def send_announcement_helper(audience)
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

  private

  def newsletter_params
    params
      .require(:newsletter)
      .permit(
        :message,
        :background_color,
        :sent_at,
        :ready,
        :user_id,
        :hero_image,
        :audience,
        :recipients,
        :template,
        :header,
        :subject,
        :action_button,
        :featured_posts,
        :subheader,
      )
  end

  def find_newsletter
    @newsletter = Newsletter.find(params[:id])
  end
end
