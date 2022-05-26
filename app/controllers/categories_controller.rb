class CategoriesController < ApplicationController
  before_action :find_category, only: %i[show edit update destroy]
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
    if @category.update category_params
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
      .permit(:name, :image, :created_at, :description, :slug, :archive)
  end

  def find_category
    @category = Category.friendly.find(params[:id])
  end
end
