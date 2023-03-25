class NewslettersController < ApplicationController
  before_action :authenticate_user!
  before_action :is_admin?
  before_action :find_newsletter, except: %i[index new create]

  def index
    @newsletters = Newsletter.order("created_at desc")
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

  def featured
    set_meta_tags title: "Choose featured | The Teen Magazine"
    @newsletter = Newsletter.find(params[:id])
    @newsletter_posts = @newsletter.posts
    if current_user.admin || current_user.has_newsletter_permissions
      if params[:search].present?
        @query = params[:search][:query]
        @pagy, @posts =
          pagy(
            Post.published.where("lower(title) LIKE ?", "%#{@query.downcase}%"),
            page: params[:page],
            items: 15,
          )
      else
        @pagy, @posts =
          pagy(Post.published.trending, page: params[:page], items: 15)
      end
    else
      redirect_to "/writers/#{current_user.slug}"
    end
  end

  #show application to editor
  #form for creating a new user already filled out
  def show
    @posts = @newsletter.posts
  end

  def send_test_newsletter
    @user = User.find(params[:user_id])
    @newsletter = Newsletter.find(params[:id])
    if @newsletter.template.eql? "Weekly Picks"
      ApplicationMailer.weekly_newsletter(@user.email, @newsletter).deliver
      redirect_to "/newsletters/#{params[:id]}", notice: "Test email sent to #{@user.email}"
    elsif @newsletter.template.eql? "Announcement"
      ApplicationMailer.custom_message_template(@user, @newsletter).deliver
      redirect_to "/newsletters/#{params[:id]}", notice: "Test email sent to #{@user.email}"
    end
  end

  def send_to_audience
    @newsletter.update_column(:sent_at, Time.now)
    Thread.new do
      recipients = 0
      if @newsletter.audience.eql? "All Writers"
        User.all.each do |user|
          if !user.do_not_send_emails
            ApplicationMailer.custom_message_template(user, @newsletter).deliver
            recipients = recipients + 1
          end
        end
      elsif @newsletter.audience.eql? "Editors"
        User.editor.each do |editor|
          if !editor.do_not_send_emails
            ApplicationMailer.custom_message_template(editor, @newsletter).deliver
            recipients = recipients + 1
          end
        end
      end
      @newsletter.update_column(:recipients, recipients)
    end
    redirect_to "/newsletters", notice: "Email is sending to #{@newsletter.audience}"
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
      )
  end

  def find_newsletter
    @newsletter = Newsletter.find(params[:id])
  end
end
