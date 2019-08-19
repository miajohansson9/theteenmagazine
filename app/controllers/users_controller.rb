class UsersController < ApplicationController
  skip_before_filter :verify_authenticity_token
  before_action :find_user, only: [:show, :edit, :update, :destroy]
  # before_action :authenticate_user!, only: [:show]
  before_action :is_admin?, only: [:index, :new]
  # load_and_authorize_resource

  def show
    @user = User.find(params[:id])
    @user_posts = @user.posts.all.order("created_at desc")
    @user_posts_approved = @user.posts.all.approved.order("created_at desc")
    @posts = Post.all.order("created_at desc");
    if @user_posts_approved.length <= 3
      begin
        if (current_user.id != @user.id && !current_user.admin?)
          redirect_to root_path, notice: "This writer does not have a public profile yet."
        end
      rescue
        redirect_to root_path, notice: "This writer does not have a public profile yet."
      end
    end
    @rankings = User.all.order("monthly_views desc").pluck(:id)
  end

  def index
    @users = User.all.order("created_at desc")
    @posts_waiting = Post.all.waiting_for_approval
  end

  def edit
  end

  def new
    @user = User.new
  end

  def create
    @user = User.new(user_params)
    @user.save

    if @user.save
      redirect_to @user, notice: "Your changes were successfully saved!"
    else
      render 'new', notice: "Oh no! Your changes were not able to be saved!"
    end
  end

  def update
    if @user.update user_params
      redirect_to @user, notice: "Your changes were saved!"
    else
      render 'edit'
    end
  end

  def destroy
    @user.destroy
    redirect_to users_path
  end

  def is_admin?
    redirect_to root_path unless (current_user && (current_user.admin? || current_user.editor?))
  end

  private

  def user_params
    params.require(:user).permit(:email, :editor, :full_name, :admin, :first_name, :last_name, :category, :nickname, :posts_count, :image, :description, :slug, :website, :unconfirmed_email, :monthly_views, :profile, :insta, :twitter, :facebook, :pintrest, :youtube, :snap)
  end

  def find_user
    @user = User.friendly.find(params[:id])
  end
end
