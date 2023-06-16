include NewslettersHelper

class NewslettersController < ApplicationController
  before_action :authenticate_user!
  before_action :is_admin?, only: %i[index]
  before_action :is_manager?, except: %i[show send_user_email create update]
  before_action :find_newsletter, except: %i[index new create send_user_email manage_newsletters]

  def index
    set_meta_tags title: "Newsletters | The Teen Magazine"
    @pagy, @newsletters =
      pagy(
        Newsletter.order("created_at desc"),
        page: params[:page],
        items: 20,
      )
  end

  def manage_newsletters
    set_meta_tags title: "Newsletters | The Teen Magazine"
    @user = User.find(params[:manager_id])
    if (current_user.id.eql? @user.id) || current_user.admin?
      @pagy, @newsletters =
        pagy(
          Newsletter.where(user_id: @user.id).order("created_at desc"),
          page: params[:page],
          items: 20,
        )
    else
      redirect_to "/newsletters/manage/#{current_user.slug}", notice: "You can only view your own emails."
    end
  end

  def get_audiences
    @audiences = []
    if current_user.admin?
      @audiences = ["All Writers", "All Readers", "Only Editors", "Only Interviewers"]
    elsif current_user.is_manager_of_category('interviews')
      @audiences = ["Only Interviewers", "Only Editors"]
    else
      @audiences = ["Only Editors"]
    end
    if current_user.is_manager?
      current_user.categories.where.not(slug: "interviews").each do |category|
        @audiences.push("Writers in #{category.name.titleize}")
      end
    end
  end

  def new
    get_audiences
    @newsletter = current_user.newsletters.new
  end

  def send_user_email
    @user = User.find(params[:recipient_id])
    if current_user.is_manager? || @user.is_manager?
      @newsletter = current_user.newsletters.build(recipient_id: @user.id, template: "Plain")
    else
      redirect_to current_user, notice: "You do not have access to this page."
    end
  end

  def edit
    if !current_user.admin? && !(current_user.id.eql? @newsletter.user.id)
      redirect_to "/newsletters/manage/#{current_user.id}", notice: "You do not have access to this page."
    end
    get_audiences
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
      if @newsletter.recipient_id.present?
        @recipient = User.find(@newsletter.recipient_id)
        ApplicationMailer.plain_message_template(@recipient, @newsletter).deliver!
        @newsletter.update_columns({
          sent_at: Time.now,
          recipients: 1,
        })
        @recipient.subscriber.update_column("last_email_sent_at", Time.now)
        redirect_to @newsletter, notice: "Message sent to #{@recipient.full_name}"
      else
        redirect_to @newsletter
      end
    else
      render "new", notice: "Something went wrong"
    end
  end

  def destroy
    @newsletter.posts.map { |p| p.update_column(:newsletter_id, nil) }
    if @newsletter.destroy
      redirect_to "/newsletters/manage/#{current_user.slug}", notice: "Your newsletter was deleted."
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
    if (current_user && (current_user.admin? || current_user.has_newsletter_permissions))
      true
    else
      redirect_to "/newsletters/manage/#{current_user.slug}"
    end
  end

  def is_manager?
    if (current_user && current_user.is_manager?)
      true
    else
      redirect_to current_user, notice: "You do not have access to this page."
    end
  end

  #show application to editor
  #form for creating a new user already filled out
  def show
    if !current_user.admin? && !(current_user.id.eql? @newsletter.user.id)
      redirect_to "/newsletters/manage/#{current_user.id}", notice: "You do not have access to this page."
    end
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
        redirect_to "/newsletters/manage/#{current_user.slug}", notice: "Something went wrong"
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
      send_announcement(@newsletter, true)
    elsif @newsletter.template.eql? "Weekly Picks"
      send_editor_picks(@newsletter, true)
    end
    redirect_to "/newsletters/manage/#{@newsletter.user.slug}", notice: "Email is sending to #{@newsletter.audience}"
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
        :recipient_id,
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
