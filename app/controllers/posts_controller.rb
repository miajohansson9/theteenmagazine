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
    if @post.approved && @post.after_approved
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
    @posts = Post.approved.all.order("created_at desc").paginate(page: params[:page], per_page: 15)
  end

  def new
    @categories = Category.all
    @post = current_user.posts.build
  end

  def create
    @categories = Category.all
    @prev_post_pitch = current_user.posts.where(pitch_id: post_params[:pitch_id]).last
    if !@prev_post_pitch.nil?
      @prev_post_pitch.pitch.claimed_id = current_user.id
      @prev_post_pitch.pitch.save
      redirect_to @prev_post_pitch, notice: "You've reclaimed this pitch!"
    else
      @post = current_user.posts.build(post_params)
      if (@post.content.include? "instagram.com/p/") && !(@post.content.include? "instgrm.Embeds.process()")
          @post.content = @post.content << "<script>instgrm.Embeds.process()</script>"
      end
      if @post.save && @post.approved && @post.after_approved
        redirect_to @post, notice: "Congrats! Your post was successfully published on The Teen Magazine!"
      elsif @post.save && !@post.pitch.nil? && @post.pitch.claimed_id.nil?
        @post.thumbnail = @post.pitch.thumbnail
        @post.save
        @post.pitch.claimed_id = current_user.id
        @post.pitch.save
        redirect_to @post, notice: "You've claimed this pitch!"
      elsif @post.save
        redirect_to @post, notice: "Changes were successfully saved!"
      else
        render 'new', notice: "Oh no! Your post was not able to be saved!"
      end
    end
  end

  def show
    redirect_to root_path unless (@post.approved || (current_user && (@post.user_id == current_user.id || @post.collaboration == current_user.email || current_user.admin? || current_user.editor?)))
    set_meta_tags title: @post.title,
                  description: @post.meta_description,
                  keywords: @post.keywords
  end

  def unapprove
    @post = Post.unscoped.update(params[:approve], :approved => false)
    render :action => :success if @post.save
  end

  def edit
    @categories = Category.all
  end

  def update
    @categories = Category.all
    if @post.update post_params
      if (@post.content.include? "instagram.com/p/") && !(@post.content.include? "instgrm.Embeds.process()")
          @post.content << "<script>instgrm.Embeds.process()</script>"
      end
      @post.save
      redirect_to @post, notice: "Changes were successfully saved!"
    else
      render 'edit'
    end
  end

  def destroy
    if !@post.pitch.try(:claimed_id).nil?
      @post.pitch.claimed_id = nil
      @post.pitch.save
    end
    @post.destroy
    redirect_to current_user, notice: "Your article was deleted."
  end

  private

  def post_params
    params.require(:post).permit(:title, :thumbnail, :ranking, :content, :image, :category_id, :post_impressions, :meta_description, :keywords, :user_id, :admin_id, :pitch_id, :waiting_for_approval, :approved, :collaboration, :after_approved, :created_at, :slug)
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
