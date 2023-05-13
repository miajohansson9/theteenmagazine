include CategoriesHelper
class CategoriesController < ApplicationController
  before_action :find_category, except: %i[index]
  before_action :authenticate_user!, except: %i[index show]

  def index
    redirect_to root_path
  end

  def new
    @category = Category.new if (user_signed_in? && current_user.admin?)
  end

  def show
    set_meta_tags title: @category.name,
                  image: @category.image,
                  description: @category.description,
                  fb: {
                    app_id: '1190455601051741'
                  },
                  og: {
                    image: {
                      url: @category.image,
                      alt: 'The Teen Magazine'
                    },
                    site_name: 'The Teen Magazine'
                  },
                  article: {
                    publisher: 'https://www.facebook.com/theteenmagazinee'
                  },
                  twitter: {
                    card: 'summary_large_image',
                    site: '@theteenmagazin_',
                    title: 'The Teen Magazine',
                    description: @category.description,
                    image: @category.image,
                    domain: 'https://www.theteenmagazine.com/'
                  }
    @pagy, @category_posts =
      pagy(
        Post.where(category_id: @category.id).published.by_published_date,
        page: params[:page],
        items: 15
      )
  end

  def dashboard
    @user = @category.user
    @published_in_category = []
    @drafts_in_category = []
    # populate published posts
    @bucket = Time.now - 13.days
    # @published = populate_published(14)
    @published_in_category = populate_published_in_category(14, @category)
    @started_in_category = populate_started_in_category(14, @category)

    # newsletter calculations
    @newsletters_sent_last_month = current_user.newsletters.where(sent_at: (Time.now - 60.days)..(Time.now - 30.days))
    @newsletters_sent_last_month = @newsletters_sent_last_month.nil? ? 0 : @newsletters_sent_last_month.count
    @newsletters_sent_this_month = current_user.newsletters.where(sent_at: (Time.now - 30.days)..(Time.now))
    @newsletters_sent_this_month = @newsletters_sent_this_month.nil? ? 0 : @newsletters_sent_this_month.count

    # published articles calculations
    @articles_last_month = Post.published.where(category_id: @category.id, publish_at: (Time.now - 60.days)..(Time.now - 30.days))
    @articles_last_month = @articles_last_month.nil? ? 0 : @articles_last_month.count
    @articles_this_month = Post.published.where(category_id: @category.id, publish_at: (Time.now - 30.days)..Time.now)
    @articles_this_month = @articles_this_month.nil? ? 0 : @articles_this_month.count
  end

  def edit
    @archive_button = @category.archive ? 'Undo Archive' : 'Archive'
    @archive_msg =
      if @category.archive
        ''
      else
        'Are you sure you want to archive this category? Writers will no longer be able to select this category.'
      end
  end

  def update
    if category_params[:image].present?
      @category.image.attach(category_params[:image])
    end
    if @category.update category_params
      if category_params[:managing_editor].present?
        @editor = User.find(category_params[:managing_editor])
        @category.user_id = @editor.id
        @category.save
      else
        @category.user_id = nil
        @category.save
      end
      redirect_to @category, notice: 'Changes were successfully saved!'
    else
      render 'edit'
    end
  end

  def destroy
    @category.destroy
    redirect_to categories_path
  end

  def create
    if (user_signed_in? && current_user.admin?)
      @category = Category.new(category_params)
    end
    @category.image.attach(category_params[:image])
    if @category.save
      redirect_to @category,
                  notice:
                    'The category was successfully added to The Teen Magazine!'
    elsif @category.save
      redirect_to @category,
                  notice: 'Changes to category were successfully saved!'
    else
      render 'new', notice: 'Oh no! Your category was not saved!'
    end
  end

  private

  def category_params
    params
      .require(:category)
      .permit(:name, :image, :created_at, :description, :slug, :archive, :user_id, :managing_editor)
  end

  def find_category
    @category = Category.friendly.find(params[:id])
  end
end
