class PostsController < ApplicationController
  before_action :find_post_history, only: [:show]
  before_action :find_post, only: [:edit, :update, :destroy]
  before_action :authenticate_user!, except: [:index, :show]
  before_action :load_user,  only: [:show]
  before_action :create,  only: [:unapprove]
  before_filter :log_impression, :only=> [:show]
  load_and_authorize_resource

  layout "article", only: [:show]
  layout "minimal", except: [:show]

  def load_user
    if @post.user != nil
      @user = @post.user
    end
  end

  def log_impression
    if @post.is_published?
      if user_signed_in? && ((@post.user.id == current_user.id) || (current_user.admin == true) || (current_user.editor == true) || (current_user.full_name == @post.collaboration))
      else
        if @post.post_impressions == nil
          @post.post_impressions = 1
          @post.save
        else
          @post.increment(:post_impressions, by = 1)
          @post.save
        end
        if @post.user.monthly_views == nil
          @post.user.monthly_views = 1
          @post.user.save
        else
          @post.user.increment(:monthly_views, by = 1)
          @post.user.save
        end
      end
    end
   end

  def index
    @posts = Post.published.all.order("created_at desc").paginate(page: params[:page], per_page: 15)
  end

  def new
    @categories = Category.all
    @post = current_user.posts.build
    @review = @post.reviews.build(status: "In Progress", active: true)
  end

  def create
    @categories = Category.all
    @prev_post_pitch = current_user.posts.where(pitch_id: post_params[:pitch_id]).last
    if !@prev_post_pitch.try(:pitch).nil?
      @prev_post_pitch.pitch.claimed_id = current_user.id
      @prev_post_pitch.pitch.save
      @prev_post_pitch.reviews.destroy
      @prev_post_pitch.reviews.build(status: "In Progress", active: true)
      @prev_post_pitch.title = Pitch.find(post_params[:pitch_id]).title
      @prev_post_pitch.save
      redirect_to @prev_post_pitch, notice: "You've reclaimed this pitch!"
    else
      @post = current_user.posts.build(post_params)
      if (@post.content.include? "instagram.com/p/") && !(@post.content.include? "instgrm.Embeds.process()")
          @post.content = @post.content << "<script>instgrm.Embeds.process()</script>"
      end
      if @post.save && @post.is_published?
        redirect_to @post, notice: "Congrats! Your post was successfully published on The Teen Magazine!"
      elsif @post.save && !@post.pitch.nil? && @post.pitch.claimed_id.nil?
        @post.thumbnail = @post.pitch.thumbnail
        @post.save
        @post.pitch.claimed_id = current_user.id
        @post.pitch.save
        @post.reviews.build(status: "In Progress", active: true)
        @post.save
        redirect_to @post, notice: "You've claimed this pitch!"
      elsif @post.save
        redirect_to @post, notice: "Changes were successfully saved!"
      else
        render 'new', notice: "Oh no! Your post was not able to be saved!"
      end
    end
  end

  def show
    @date = @post.is_published? ? @post.publish_at : @post.created_at
    if (@post.is_published? || (current_user && (@post.sharing || @post.user_id == current_user.id || @post.collaboration == current_user.email || current_user.admin? || current_user.editor?)))
      if !params[:sharing].nil? && (current_user.id = @post.id || current_user.admin || current_user.editor)
        @post.sharing = params[:sharing]
        @post.save
        @message = @post.sharing ? "Peer sharing is turned on!" : "Peer sharing is turned off."
        redirect_to @post, notice: @message
      end
      if @post.sharing
        @comment = current_user.comments.build(post_id: @post.id)
      end
      if !@post.is_published?
        @comments = @post.comments.order("created_at asc")
      else
         @trending = @post.category.posts.published.order("post_impressions desc").limit(7)
      end
      set_meta_tags title: @post.title,
                    description: @post.meta_description,
                    keywords: @post.keywords
    else
      redirect_to new_user_session_path, notice: "You must sign in to continue."
    end
  end

  def unapprove
    @post = Post.unscoped.update(params[:approve], :approved => false)
    render :action => :success if @post.save
  end

  def edit
    @categories = Category.all
    #create new review if no current review or last review was rejected
    @review = (@post.reviews.last.nil?) || (@post.reviews.last.try(:status).eql? "Rejected") ? @post.reviews.build(active: true, feedback_givens: @post.reviews.last.feedback_givens) : @post.reviews.last
    @feedbacks = Feedback.all
    @requested_changes = @review.feedback_givens
  end

  def update
    @categories = Category.all
    @prev_review = @post.reviews.last.clone
    @prev_status = @post.reviews.last.status.clone
    if @post.update! post_params
      if (@post.content.include? "instagram.com/p/") && !(@post.content.include? "instgrm.Embeds.process()")
        @post.content << "<script>instgrm.Embeds.process()</script>"
      end
      @new_status = @post.reviews.last.status.clone
      @post.publish_at = nil
      if (@new_status.eql? "In Progress") && (@prev_status.eql? "Rejected")
        @post.reviews.last.destroy
      else
        @post.reviews.each do |review|
          review.active = false
        end
        if @new_status.eql? "In Review"
          @post.reviews.last.editor_id = current_user.id
        end
        @post.reviews.last.feedback_givens.each do |feedback|
          feedback.destroy
        end
        @feedback_given = post_params[:feedback_list]
        @feedback_given.try(:each) do |feedback_id|
          @feedback = Feedback.find(feedback_id)
          @critique = @feedback.feedback_givens.build(review_id: @post.reviews.last.id)
          @critique.save
        end
        @post.reviews.last.active = true
        @post.reviews.last.save!
        if (@new_status.eql? "Approved for Publishing") && !(@prev_status.eql? "Approved for Publishing")
          if @post.user.posts.published.count.eql? 0
            ApplicationMailer.first_article_published(@post.user, @post).deliver
          else
            ApplicationMailer.article_published(@post.user, @post).deliver
          end
          @post.publish_at = Time.now
        end
      end
      @post.save
      if (@new_status.eql? "In Progress") && ((@prev_status.eql? "Ready for Review") || (@prev_status.eql? "In Review"))
        @notice = "Your article was withdrawn from review."
      elsif ((@prev_status.eql? "In Progress") || (@prev_status.blank?)) && (@new_status.eql? "Ready for Review")
        ApplicationMailer.article_moved_to_submitted(@post.user, @post).deliver
        @notice = "Your article was submitted for review."
      else
        @notice = "Your changes were saved."
      end
      if @new_status.eql? "Rejected"
        ApplicationMailer.article_has_requested_changes(@post.user, @post).deliver
      end
      if @new_status.eql? "In Review"
        @notice = @prev_review.editor_id == current_user.id ? "Your changes were saved." : "Great job! You've claimed editing this article!"
        if !@prev_status.eql? "In Review"
          ApplicationMailer.article_moved_to_review(@post.user, @post).deliver
        end
        redirect_to reviews_path, notice: @notice
      else
        redirect_to @post, notice: @notice
      end
    else
      render 'edit', notice: "Changes were unable to be saved."
    end
  end

  def destroy
    if !@post.pitch.nil?
      if @post.pitch.claimed_id.eql? @post.user.id
        @post.pitch.claimed_id = nil
        @post.pitch.save
      end
    end
    @post.destroy
    redirect_to current_user, notice: "Your article was deleted."
  end

  private

  def post_params
    params.require(:post).permit(:title, :thumbnail, :ranking, :content, :image, :category_id, :post_impressions, :meta_description, :keywords, :user_id, :admin_id, :pitch_id, :waiting_for_approval, :approved, :sharing, :collaboration, :after_approved, :created_at, :publish_at, :slug, :feedback_list => [], :reviews_attributes => [:id, :post_id, :created_at, :status, :notes])
  end

  def find_post_history
    begin
      @post = Post.friendly.find params[:id]
      if request.path != post_path(@post)
        return redirect_to @post, :status => :moved_permanently
      end
    rescue
      redirect_to root_path
    end
  end

  def find_post
    begin
      @post = Post.friendly.find params[:id]
    rescue
      redirect_to root_path
    end
  end
end
