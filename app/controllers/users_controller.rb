class UsersController < ApplicationController
  skip_before_filter :verify_authenticity_token
  before_action :find_user, only: [:show, :edit, :update, :destroy]
  before_action :authenticate_user!, except: [:index, :show]
  before_action :is_admin?, only: [:index, :new]
  layout :set_layout

  def show
    @user_posts = @user.posts.all.order("created_at desc")
    @user_posts_approved = @user.posts.published.order("created_at desc")
    @posts = Post.all.order("created_at desc");
    if @user_posts_approved.length < 1
      begin
        if (current_user.id != @user.id && (!current_user.admin?) && (!current_user.editor?))
          redirect_to root_path, notice: "This writer does not have a public profile yet."
        elsif (current_user.submitted_profile == nil)
          redirect_to "/onboarding"
        end
      rescue
        redirect_to root_path, notice: "This writer does not have a public profile yet."
      end
    end
    @pitches = Pitch.all.order("created_at desc").limit(4)
    @claimed_pitches_cnt =  Pitch.where(claimed_id: current_user.id).present? ? Pitch.where(claimed_id: current_user.id).count : 0;
    @published_articles_cnt =  @user.posts.published.count;
    @pageviews = 0
    @user_posts_approved.each do |post|
      if !post.post_impressions.nil?
        @pageviews += post.post_impressions
      end
    end
  end

  def onboarding
    @user = current_user
    @partial = params[:page] || "welcome" || "your_profile" || "next_steps" || "done"
  end

  def index
    @users = User.all.order("created_at desc")
    @posts_waiting = Post.all.submitted
    @users_waiting = User.all.review_profile
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
    if @user.approved_profile == false && user_params[:approved_profile] == "1"
      ApplicationMailer.profile_approved(@user).deliver
    end
    if @user.update user_params
      if params[:redirect] != nil
        redirect_to onboarding_path(page: params[:redirect])
      else
        redirect_to @user, notice: "Your profile has been updated."
      end
    else
      render 'edit', alert: "Changes were unable to be saved."
    end
  end

  def destroy
    @user.destroy
    redirect_to users_path
  end

  def is_admin?
    redirect_to root_path unless (current_user && (current_user.admin? || current_user.editor?))
  end

  def set_layout
    current_user ? "minimal" : "application"
  end

  private

  def user_params
    params.require(:user).permit(:email, :editor, :full_name, :admin, :first_name, :last_name, :category, :submitted_profile, :approved_profile, :nickname, :posts_count, :image, :description, :slug, :website, :unconfirmed_email, :monthly_views, :profile, :insta, :twitter, :facebook, :pintrest, :youtube, :snap)
  end

  def find_user
    @user = User.friendly.find(params[:id])
  end
end
