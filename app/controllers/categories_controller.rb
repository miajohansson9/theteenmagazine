class CategoriesController < ApplicationController
  layout "category"
  before_action :find_category, only: [:show, :edit, :update, :destroy]
  before_action :authenticate_user!, except: [:index, :show]

  def index
    redirect_to root_path
  end

  def new
    if (user_signed_in? && current_user.admin?)
      @category = Category.new
    end
  end

  def show
    set_meta_tags title: @category.name,
                  image: @category.image,
                  description: @category.description,
                  :fb => {
                    :app_id => "1190455601051741"
                  },
                  :og => {
                    :image => {
                      :url => @category.image,
                      :alt => 'The Teen Magazine',
                    },
                    :site_name => "The Teen Magazine",
                  },
                  :article => {
                    :publisher => "https://www.facebook.com/theteenmagazinee"
                  },
                  :twitter => {
                    :card => "summary_large_image",
                    :site => "@theteenmagazin_",
                    :title => "The Teen Magazine",
                    :description => @category.description,
                    :image => @category.image,
                    :domain => "https://www.theteenmagazine.com/"
                  }
    @category_posts = Post.where(category_id: @category.id).published.all.paginate(page: params[:page], per_page: 15).order("publish_at desc")
  end

  def edit
  end

  def update
    if @category.update category_params
      redirect_to @category, notice: "Changes were successfully saved!"
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
      redirect_to @category, notice: "The category was successfully added to The Teen Magazine!"
    elsif @category.save
      redirect_to @category, notice: "Changes to category were successfully saved!"
    else
      render 'new', notice: "Oh no! Your category was not saved!"
    end
  end

  private

  def category_params
    params.require(:category).permit(:name, :image, :created_at, :description, :slug)
  end

  def find_category
    @category = Category.friendly.find(params[:id])
  end
end
