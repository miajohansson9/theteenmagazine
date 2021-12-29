class NewslettersController < ApplicationController
  before_action :authenticate_user!
  before_action :is_admin?
  before_action :find_newsletter, except: %i[index new]

  def index
    @newsletters = Newsletter.where.not(kind: nil).order('created_at desc')
  end

  def new
    @newsletter =
      Newsletter.find_by(kind: nil) || current_user.newsletters.create
    @pagy, @posts =
      pagy(
        Post.published.where(newsletter_id: nil),
        page: params[:page],
        items: 20
      )
    @newsletter_posts = []
    @disabled = true
  end

  def edit
    @posts = Post.published.where(newsletter_id: nil)
    @newsletter_posts = @newsletter.posts || []
    @newsletters_to_send_before_cnt =
      Newsletter
        .where(sent_at: nil)
        .where('created_at < ?', @newsletter.created_at)
        .count
    @disabled = @newsletter_posts.count < 5
  end

  def create
    @newsletter = current_user.newsletters.build(newsletter_params)
    @newsletter.save
  end

  def destroy
    @newsletter.posts.map { |p| p.update_column(:newsletter_id, nil) }
    if @newsletter.destroy
      redirect_to newsletters_path, notice: 'Your newsletter was deleted.'
    end
  end

  def update
    if @newsletter.update newsletter_params
      redirect_to @newsletter, notice: 'Your changes were saved.'
    else
      render 'new'
    end
  end

  #only allow admin can send/create newsletters
  def is_admin?
    if (
         current_user &&
           (current_user.admin? || current_user.has_newsletter_permissions)
       )
      true
    else
      redirect_to current_user, notice: 'You do not have access to this page.'
    end
  end

  def featured
    set_meta_tags title: 'Choose featured | The Teen Magazine'
    @newsletter = Newsletter.find(params[:id])
    @newsletter_posts = @newsletter.posts
    if current_user.admin || current_user.has_newsletter_permissions
      @posts = @newsletter.posts || 0
      if params[:search].present?
        @query = params[:search][:query]
        @pagy, @posts =
          pagy(
            Post.published.where('lower(title) LIKE ?', "%#{@query.downcase}%"),
            page: params[:page],
            items: 15
          )
      else
        @pagy, @posts =
          pagy(Post.published.trending, page: params[:page], items: 15)
      end
    else
      redirect_to "/writers/#{current_user.slug}/newsletters"
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
    ApplicationMailer.weekly_newsletter(@user.email, @newsletter).deliver
    redirect_to "/newsletters/#{params[:id]}",
                notice: "Test email sent to #{@user.email}"
  end

  private

  def newsletter_params
    params
      .require(:newsletter)
      .permit(
        :message,
        :kind,
        :background_color,
        :sent_at,
        :ready,
        :user_id,
        :hero_image
      )
  end

  def find_newsletter
    @newsletter = Newsletter.find(params[:id])
  end
end
