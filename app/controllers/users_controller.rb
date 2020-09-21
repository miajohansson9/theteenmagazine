class UsersController < ApplicationController
  skip_before_filter :verify_authenticity_token
  before_action :find_user, only: [:show, :edit, :update, :destroy, :pageviews]
  before_action :authenticate_user!, except: [:index, :show]
  before_action :is_admin?, only: [:show_users, :new]
  layout :set_layout

  def show
    set_meta_tags title: "#{@user.full_name} | The Teen Magazine",
                  description: @user.description
    @user_posts = Post.where("collaboration like ?", "%#{@user.email}%").or(Post.where(user_id: @user.id)).order("updated_at desc")
    @user_posts_approved = Post.where("collaboration like ?", "%#{@user.email}%").or(Post.where(user_id: @user.id)).published.order("publish_at desc")
    if !@user.editor? && current_user.present?
      @user_pitches = @user.pitches.not_claimed.order("updated_at desc")
    elsif @user.editor?
      @editor_pitches_cnt =  @user.pitches.count
      @editor_reviews = Review.where(editor_id: @user.id)
      @editor_reviews_cnt = @editor_reviews.count
      @writers_helped_cnt = @editor_reviews.map{|r| r.post.try(:user_id)}.uniq.count
    end
    if @user_posts_approved.length < 1
      begin
        if (current_user.id != @user.id && (!current_user.admin?) && (!current_user.editor?))
          redirect_to(:back, notice: "This writer does not have a public profile yet.")
        elsif (current_user.submitted_profile == nil)
          redirect_to "/onboarding", notice: "You must complete the onboarding process first."
        end
      rescue
        redirect_to(:back, notice: "This writer does not have a public profile yet.")
      end
    end
    if current_user.present?
      @pitches = Pitch.all.order("created_at desc").limit(4)
      @featured_writers = Post.where(publish_at: (Time.now - 7.days)..Time.now).order("updated_at desc").map{|p| p.user}.uniq
      @claimed_pitches_cnt =  Pitch.where(claimed_id: @user.id).present? ? Pitch.where(claimed_id: @user.id).count : 0;
      @pageviews = 0
      @user_posts_approved.each do |post|
        if !post.post_impressions.nil?
          @pageviews += post.post_impressions
        end
      end
    end
  end

  def onboarding
    @user = current_user
    @partial = params[:page] || "welcome" || "your_profile" || "next_steps" || "done"
  end

  def index
    if params[:commit].eql? "Send reset link"
      reset_email
    elsif current_user && (current_user.admin? || current_user.editor?)
      set_meta_tags title: "Writers | The Teen Magazine"
      show_users
    elsif current_user
      redirect_to current_user, notice: "You do not have access to this page."
    else
      redirect_to "/login", notice: "You must sign in before continuing."
      store_location_for(:user, request.fullpath)
    end
  end

  def show_users
    @users = User.all.paginate(page: params[:page]).order("created_at desc")
    @posts_waiting = Post.all.submitted
    @users_waiting = User.all.review_profile
  end

  def reset_email
    begin
      User.where(email: params[:user][:email].strip).first.send_reset_password_instructions
      redirect_to "/reset-password", notice: "A reset password email was sent to #{params[:user][:email]}."
    rescue
      redirect_to "/reset-password", notice: "Oops, something went wrong! #{params[:user][:email]} may not be associated with a writer account."
    end
  end

  def edit
    if @user.editor?
      @editor_pitches_cnt =  @user.pitches.count
      @editor_reviews = Review.where(editor_id: @user.id)
      @editor_reviews_cnt = @editor_reviews.count
      @writers_helped_cnt = @editor_reviews.map{|r| r.post.try(:user_id)}.uniq.count
    end
    set_meta_tags title: "Edit Profile | The Teen Magazine"
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
        add_to_list(@user)
        redirect_to @user, notice: "Your profile has been updated."
      end
    else
      render 'edit', notice: "Changes were unable to be saved."
    end
  end

  def destroy
    @user.posts.each do |post|
      post.user = User.where(email: "anonymous@theteenmagazine.com").first
      post.save
    end
    @user.destroy
    redirect_to users_path, notice: "The writer account was deleted."
  end

  def is_admin?
    redirect_to root_path unless (current_user && (current_user.admin? || current_user.editor?))
  end

  def set_layout
    current_user ? "minimal" : "application"
  end

  def add_to_list(user)
    begin
      @gb = Gibbon::Request.new(api_key: ENV['MAILCHIMP_API_KEY'])
      @gb.lists(ENV['MAILCHIMP_LIST_ID']).members.create(body: {email_address: user.email, status: "subscribed"})
    rescue
      puts "Error: Failed to subscribe to mailchimp list"
    end
  end

  private

  def user_params
    params.require(:user).permit(:email, :do_not_send_emails, :editor, :marketer, :full_name, :admin, :first_name, :last_name, :category, :points, :submitted_profile, :approved_profile, :nickname, :posts_count, :image, :description, :slug, :website, :unconfirmed_email, :monthly_views, :profile, :insta, :twitter, :facebook, :pintrest, :youtube, :snap, :bi_monthly_assignment, :last_saw_pitches, :last_saw_writer_applications, :last_saw_editor_dashboard, :last_saw_peer_feedback, :last_saw_community)
  end

  def find_user
    @user = User.friendly.find(params[:id])
  end
end
