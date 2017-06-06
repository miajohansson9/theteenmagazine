class PostsController < ApplicationController
  before_action :find_post, only: [:show, :edit, :update, :destroy]
  before_action :authenticate_user!, except: [:index, :show]
  before_action :load_user,  only: [:show]
  before_action :create,  only: [:unapprove]
  load_and_authorize_resource

  def load_user
    if @post.user != nil
      @user = @post.user
    end
  end

  def index
    @posts = Post.approved.all.order("created_at desc").paginate(page: params[:page], per_page: 15)
  end

  def new
    if user_signed_in?
      @post = current_user.posts.build
    else
      @post = Post.new
    end
  end

  def create
    if user_signed_in?
      @post = current_user.posts.build(post_params)
    else
      @post = Post.new(post_params)
    end

    if @post.save && @post.approved && @post.after_approved
      redirect_to @post, notice: "Congrats! Your post was successfully published on The Teen Magazine!"
    elsif @post.save
      redirect_to @post, notice: "Changes were successfully saved!"
    else
      render 'new', notice: "Oh no! Your post was not able to be saved!"
    end
  end

  def show
    redirect_to root_path unless (@post.approved || (current_user && (@post.user_id == current_user.id || current_user.admin?)))
    set_meta_tags title: @post.title,
                  description: @post.meta_description,
                  keywords: @post.keywords
  end

  def unapprove
    @post = Post.unscoped.update(params[:approve], :approved => false)
    render :action => :success if @post.save
  end

  def edit
  end

  def update
    if @post.update post_params
      redirect_to @post, notice: "Changes were successfully saved!"
    else
      render 'edit'
    end
  end

  def destroy
    @post.destroy
    redirect_to posts_path
  end

  private

  def post_params
    params.require(:post).permit(:title, :thumbnail, :content, :image, :category, :category_id, :meta_title, :meta_description, :keywords, :user_id, :admin_id, :waiting_for_approval, :approved, :after_approved, :created_at, :slug)
  end

  def find_post
    @post = Post.friendly.find(params[:id])
  end
end
