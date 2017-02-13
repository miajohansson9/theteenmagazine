class UsersController < ApplicationController
  before_action :find_user, only: [:show, :edit, :update, :destroy]
  before_action :authenticate_admin!, only: [:index]
  before_action :authenticate_any!, only: [:show]

  def authenticate_any!
    if admin_signed_in?
        authenticate_admin!
    else
        authenticate_user!
    end
  end

  def show
    @user = User.find(params[:id])
    @user_posts = @user.posts
  end

  def index

    @users = User.all.order("created_at desc")
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
    redirect_to root_path
  end

  private

  def user_params
    params.require(:user).permit(:email, :first_name, :last_name, :image, :description, :website, :insta, :twitter, :facebook, :pintrest, :youtube, :snap)
  end

  def find_user
    @user = User.find(params[:id])
  end
end
