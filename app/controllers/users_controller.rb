class UsersController < ApplicationController
  skip_before_filter :verify_authenticity_token
  before_action :find_user, only: [:show, :edit, :update, :destroy, :pageviews, :share, :redirect]
  before_action :authenticate_user!, except: [:index, :show, :redirect]
  before_action :is_editor?, only: [:show_users, :new]
  before_action :is_admin?, only: [:new, :partners, :share]
  layout :set_layout

  def show
    set_meta_tags title: "#{@user.full_name} | The Teen Magazine",
                  description: @user.description
    if @user.partner
      redirect_to "/partners/#{@user.slug}"
    end
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
        end
      rescue
        redirect_to(:back, notice: "This writer does not have a public profile yet.")
      end
    end
    if current_user.present?
      @pitches = Pitch.where.not(status: "Rejected").all.order("created_at desc").limit(4)
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

  def partner
    @partner = User.where(partner: true).find(params[:id])
    set_meta_tags title: "#{@partner.full_name} | The Teen Magazine"
    @posts = Post.where(partner_id: @partner.id).where(publish_at: nil)
    @published = Post.published.where(partner_id: @partner.id)
    @pageviews = 0
    @published.each do |post|
      if !post.post_impressions.nil?
        @pageviews += post.post_impressions
      end
    end
  end

  def sponsored
    @partner = User.where(partner: true).find(params[:id])
    set_meta_tags title: "#{@partner.full_name} Published Articles | The Teen Magazine"
    @published = Post.published.where(partner_id: @partner.id)
  end

  def onboarding
    @user = current_user
    @partial = params[:page] || "welcome" || "your_profile" || "next_steps" || "done"
  end

  def editor_onboarding
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
    @users = User.where(partner: [nil, false]).all.paginate(page: params[:page], per_page: 25).order("created_at desc")
    @users_waiting = User.all.review_profile
  end

  def partners
    set_meta_tags title: "Partners | The Teen Magazine"
    @partners = User.where(partner: true).all.paginate(page: params[:page], per_page: 25).order("created_at desc")
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
    set_meta_tags title: "New Partner | The Teen Magazine"
  end

  def create
    @user = User.new(user_params)
    if @user.save
      if @user.partner
        ApplicationMailer.partner_login_details(current_user, @user).deliver
        redirect_to "/partners/#{@user.slug}", notice: "A new partner was added!"
      else
        redirect_to @user, notice: "Your changes were successfully saved!"
      end
    else
      render 'new', notice: "Oh no! Your changes were not able to be saved!"
    end
  end

  def update
    if @user.approved_profile == false && user_params[:approved_profile] == "1"
      ApplicationMailer.profile_approved(@user).deliver
    end
    if @user.update user_params
      if @user.first_name.present? && @user.last_name.present?
        @user.full_name = "#{@user.first_name} #{@user.last_name}"
        @user.save
      end
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
    if @user.partner
      Post.where(partner_id: @user.id).each do |post|
        post.partner_id = nil
        post.save
      end
    end
    @user.posts.each do |post|
      post.user = User.where(email: "anonymous@theteenmagazine.com").first
      post.save
    end
    @user.comments.destroy_all
    @user.destroy
    redirect_to users_path, notice: "The writer account was deleted."
  end

  def redirect
    if @user.partner
      redirect_to "/partners/#{@user.slug}"
    else
      redirect_to "/writers/#{@user.slug}"
    end
  end

  def share
    set_meta_tags title: "Add Partner to Article | The Teen Magazine"
    if params[:search].present?
      @query = params[:search][:query]
      @posts = Post.draft.where(partner_id: nil).where("lower(title) LIKE ?", "%#{@query.downcase}%").order("publish_at desc").paginate(page: params[:page], per_page: 15)
    else
      @posts = Post.draft.where(partner_id: nil).paginate(page: params[:page], per_page: 15).order("publish_at desc")
    end
  end

  def is_admin?
    if (current_user && current_user.admin?)
      true
    else
      redirect_to current_user, notice: "You do not have access to this page."
    end
  end

  def is_editor?
    if (current_user && (current_user.admin? || current_user.editor?))
      true
    else
      redirect_to current_user, notice: "You do not have access to this page."
    end
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
    params.require(:user).permit(:email, :password, :do_not_send_emails, :editor, :marketer, :partner, :full_name, :admin, :first_name, :last_name, :category, :points, :submitted_profile, :approved_profile, :nickname, :posts_count, :image, :description, :slug, :website, :unconfirmed_email, :monthly_views, :profile, :insta, :twitter, :facebook, :pintrest, :youtube, :snap, :bi_monthly_assignment, :last_saw_pitches, :last_saw_writer_applications, :last_saw_editor_dashboard, :last_saw_peer_feedback, :last_saw_community)
  end

  def find_user
    @user = User.friendly.find(params[:id])
  end
end
