include CategoriesHelper

class CategoriesController < ApplicationController
  before_action :find_category, except: %i[index new create admin_dashboard]
  before_action :authenticate_user!, except: %i[index show team]

  def index
    redirect_to root_path
  end

  def new
    @category = Category.new if (user_signed_in? && current_user.admin?)
  end

  def team
    @managing_editor = User.find_by(id: @category.user_id)
    @color = @category.color.nil? ? "#4abeb6" : @category.color
    @users = User.left_joins(:posts)
      .where(posts: { category_id: @category.id })
      .where.not(posts: { publish_at: nil })
      .group(:id)
      .order('COUNT(posts.id) DESC')
    @pagy, @team =
          pagy(
            @users,
            page: params[:page],
            items: 50,
          )
  end

  def show
    @color = @category.color.nil? ? "#4abeb6" : @category.color
    @managing_editor = User.find_by(id: @category.user_id)
    set_meta_tags title: @category.name,
                  image: @category.image,
                  description: @category.description,
                  fb: {
                    app_id: "1190455601051741",
                  },
                  og: {
                    image: {
                      url: @category.image,
                      alt: "The Teen Magazine",
                    },
                    site_name: "The Teen Magazine",
                  },
                  article: {
                    publisher: "https://www.facebook.com/theteenmagazinee",
                  },
                  twitter: {
                    card: "summary_large_image",
                    site: "@ttm_magazine",
                    title: "The Teen Magazine",
                    description: @category.description,
                    image: @category.image,
                    domain: "https://www.theteenmagazine.com/",
                  }
    if @category.slug.eql? 'interviews'
      @posts = Post.where(is_interview: true).published
    else
      @posts = Post.where(category_id: @category.id).published
    end
    if current_user.present? && current_user.is_manager? && (params[:high_priority].eql? "true")
      @posts = @posts.high_priority
    elsif current_user.present? && current_user.is_manager? && params[:popular_within].present?
      @weeks = Integer(params[:popular_within]) * 1.week
      @posts = @posts.where(publish_at: (Time.now - @weeks)..Time.now).most_viewed
    else
      @posts = @posts.by_published_date
    end
    @pagy, @category_posts =
      pagy(
        @posts,
        page: params[:page],
        items: 15,
      )
    @team = User.left_joins(:posts)
      .where(posts: { category_id: @category.id })
      .where.not(posts: { publish_at: nil })
      .distinct
    puts @team.count
  end

  def dashboard
    unless current_user? && (current_user.admin? || (current_user.categories.where(slug: @category.slug).present?))
      redirect_to @category, notice: "You do not have access to this page."
    end
    set_meta_tags title: "#{@category.name.titleize} Dashboard"
    @user = @category.user
    @published_in_category = []
    @drafts_in_category = []
    # populate published posts
    @bucket = Time.now - 13.days
    # @published = populate_published(14)
    @published_in_category = populate_published_in_category(14, @category)
    @started_in_category = populate_started_in_category(14, @category)

    # newsletter calculations
    @newsletters_user = @user.present? ? @user : current_user
    @newsletters_sent_last_month = @newsletters_user.newsletters.where(recipient_id: nil, sent_at: (Time.now - 60.days)..(Time.now - 30.days))
    @newsletters_sent_last_month = @newsletters_sent_last_month.nil? ? 0 : @newsletters_sent_last_month.count
    @newsletters_sent_this_month = @newsletters_user.newsletters.where(recipient_id: nil, sent_at: (Time.now - 30.days)..(Time.now))
    @newsletters_sent_this_month = @newsletters_sent_this_month.nil? ? 0 : @newsletters_sent_this_month.count

    # published articles calculations
    if @category.slug.eql? 'interviews'
      @articles_last_month = Post.published.where(is_interview: true, publish_at: (Time.now - 60.days)..(Time.now - 30.days))
      @articles_this_month = Post.published.where(is_interview: true, publish_at: (Time.now - 30.days)..Time.now)
    else
      @articles_last_month = Post.published.where(category_id: @category.id, publish_at: (Time.now - 60.days)..(Time.now - 30.days))
      @articles_this_month = Post.published.where(category_id: @category.id, publish_at: (Time.now - 30.days)..Time.now)
    end
    @articles_last_month = @articles_last_month.nil? ? 0 : @articles_last_month.count
    @articles_this_month = @articles_this_month.nil? ? 0 : @articles_this_month.count

    # get all drafts
    if @category.slug.eql? 'interviews'
      @category_drafts = Post.where(is_interview: true, updated_at: (Time.now - 6.months)..Time.now).order("updated_at desc")
    else
      @category_drafts = @category.posts.where(updated_at: (Time.now - 6.months)..Time.now).order("updated_at desc")
    end

    # popular articles
    @views_cut_off = 1000
    if @category.slug.eql? 'interviews'
      @popular_articles = Post.where(is_interview: true, publish_at: (Time.now - 3.months)..Time.now).where("post_impressions > ?", @views_cut_off)
    else
      @popular_articles = @category.posts.where(publish_at: (Time.now - 3.months)..Time.now).where("post_impressions > ?", @views_cut_off)
    end
    @popular_articles_count = @popular_articles.nil? ? 0 : @popular_articles.count

    # writers subscribed
    @subscribers_count = (@category.slug.eql? 'interviews') ? Subscriber.interviewer.count : @category.subscribers.count

    @high_priority_published_count = @category.posts.published.high_priority.nil? ? 0 : @category.posts.published.high_priority.count
  end

  def admin_dashboard
    unless current_user? && (current_user.admin? || (current_user.categories.where(slug: @category.slug).present?))
      redirect_to current_user, notice: "You do not have access to this page."
    end
    @user = current_user
    @published_in_category = []
    @drafts_in_category = []
    # populate published posts
    @bucket = Time.now - 13.days
    # @published = populate_published(14)
    @published_in_category = populate_published_in_all_categories(14)
    @started_in_category = populate_started_in_all_categories(14)

    # newsletter calculations
    @newsletters_user = @user.present? ? @user : current_user
    @newsletters_sent_last_month = @newsletters_user.newsletters.where(recipient_id: nil, sent_at: (Time.now - 60.days)..(Time.now - 30.days))
    @newsletters_sent_last_month = @newsletters_sent_last_month.nil? ? 0 : @newsletters_sent_last_month.count
    @newsletters_sent_this_month = @newsletters_user.newsletters.where(recipient_id: nil, sent_at: (Time.now - 30.days)..(Time.now))
    @newsletters_sent_this_month = @newsletters_sent_this_month.nil? ? 0 : @newsletters_sent_this_month.count

    # published articles calculations
    @articles_last_month = Post.published.where(publish_at: (Time.now - 60.days)..(Time.now - 30.days))
    @articles_last_month = @articles_last_month.nil? ? 0 : @articles_last_month.count
    @articles_this_month = Post.published.where(publish_at: (Time.now - 30.days)..Time.now)
    @articles_this_month = @articles_this_month.nil? ? 0 : @articles_this_month.count

    # get all drafts
    @category_drafts = Post.where(updated_at: (Time.now - 3.months)..Time.now).order("updated_at desc")

    # popular articles
    @views_cut_off = 1000
    @popular_articles = Post.where(publish_at: (Time.now - 3.months)..Time.now).where("post_impressions > ?", @views_cut_off)
    @popular_articles_count = @popular_articles.nil? ? 0 : @popular_articles.count

    # writers subscribed
    @subscribers_count = Subscriber.count
    @high_priority_published_count = Post.published.high_priority.nil? ? 0 : Post.published.high_priority.count
    
    # active
    @active_writers = User.writer.where(last_sign_in_at: (Time.now - 1.week)..Time.now).count
    @active_editors = User.editor.where(last_sign_in_at: (Time.now - 1.week)..Time.now).count
    @active_managing_editors = User.managing_editor.where(last_sign_in_at: (Time.now - 1.week)..Time.now).count
    @active_partners = User.partner.where(last_sign_in_at: (Time.now - 1.week)..Time.now).count
  end

  def edit
    if current_user && (current_user.admin? || current_user.categories.where(slug: @category.slug).present?)
      @archive_button = @category.archive ? "Undo Archive" : "Archive"
      @archive_msg = if @category.archive
          ""
        else
          "Are you sure you want to archive this category? Writers will no longer be able to select this category."
        end
    else
      redirect_to @category, notice: "You do not have access to this page."
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
      redirect_to @category, notice: "Changes were successfully saved!"
    else
      render "edit"
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
                  notice: "The category was successfully added to The Teen Magazine!"
    elsif @category.save
      redirect_to @category,
                  notice: "Changes to category were successfully saved!"
    else
      render "new", notice: "Oh no! Your category was not saved!"
    end
  end

  private

  def category_params
    params
      .require(:category)
      .permit(:name, :image, :created_at, :rank, :description, :slug, :archive, :user_id, :managing_editor, :color)
  end

  def find_category
    @category = Category.friendly.find(params[:id])
  end
end
