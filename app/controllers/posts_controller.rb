class PostsController < ApplicationController
  before_action :find_post_history, only: [:show]
  before_action :find_post, only: [:edit, :update, :destroy]
  before_action :authenticate_user!, except: [:show]
  before_action :load_user,  only: [:show]
  before_action :create,  only: [:unapprove]
  before_filter :log_impression, :only=> [:show]
  before_action :is_admin?, :only => [:new]
  before_action :is_partner?, :only => [:index, :edit]
  load_and_authorize_resource

  layout :set_layout

  def load_user
    if @post.user != nil
      @user = @post.user
      if @user.editor?
        @editor_pitches_cnt =  @user.pitches.count
        @editor_reviews = Review.where(editor_id: @user.id)
        @editor_reviews_cnt = @editor_reviews.count
        @writers_helped_cnt = @editor_reviews.map{|r| r.post.try(:user_id)}.uniq.count
      end
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
    set_meta_tags :title => "Community | The Teen Magazine"
    @notifications = @unseen_shared_drafts_cnt - @unseen_shared_drafts_cnt
    @unseen_shared_drafts_cnt = 0
    if current_user.points.nil?
      current_user.points = 0
      current_user.save
    end
    @points = current_user.points
    @my_shared_drafts = current_user.posts.where(sharing: true, publish_at: nil).draft.order("updated_at desc")
    @shared_drafts = Post.where(sharing: true).draft.order("updated_at desc").paginate(page: params[:page], per_page: 15)
    @replies  = current_user.comments.map{|c| c.comments.where.not(user_id: current_user.id)}.flatten.reject(&:blank?)
    @comments_following  = current_user.comments.where.not(comment_id: nil).map{ |c| @parent = Comment.find_by(id: c.comment_id)
                                                                                 if @parent.try(:comments).present?
                                                                                   @parent.comments.where('created_at > ?', c.created_at)
                                                                                 end
                                                                               }.flatten.reject(&:blank?).delete_if{|c| c.user_id.eql? current_user.id}
    @post_comments = current_user.posts.draft.map{|p| p.comments.where.not(user_id: current_user.id)}.flatten
    @all = (@comments_following + @post_comments + @replies).uniq.sort_by(&:created_at).reverse.take(8)
    current_user.last_saw_community = Time.now
    current_user.save
  end

  def new
    @categories = Category.all
    @service_id = ENV['WEBSPELLCHECKER_ID']
    @post = current_user.posts.build
    @review = @post.reviews.build(status: "In Progress", active: true)
  end

  def create
    @categories = Category.all
    @prev_post_pitch = current_user.posts.where(pitch_id: post_params[:pitch_id]).last
    if !(@prev_post_pitch.try(:pitch).nil?)
      @prev_post_pitch.pitch.claimed_id = current_user.id
      @prev_post_pitch.pitch.save
      @prev_post_pitch.reviews.destroy
      @prev_post_pitch.reviews.build(status: "In Progress", active: true)
      @prev_post_pitch.title = Pitch.find(post_params[:pitch_id]).title
      @prev_post_pitch.save
      redirect_to @prev_post_pitch, notice: "You've reclaimed this pitch!"
    else
      @post = current_user.posts.build(post_params)
      fix_formatting
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
    if (@post.is_published? || (current_user && (@post.sharing || @post.user_id == current_user.id || @post.partner_id == current_user.id || (@post.collaboration&.include? current_user.email) || current_user.admin? || current_user.editor?)))
      @collabs = []
      if @post.collaboration.present?
        @emails = @post.collaboration.delete(' ').split(",")
        @emails.each do |email|
          @writer = User.where(email: email).first
          if @writer.present?
            @collabs.push @writer
          end
        end
      end
      if params[:partner].present?
        @post.partner_id = nil
        @post.sharing = false
        @post.save
        redirect_to @post, notice: "Partner sharing turned off for this article"
      elsif !params[:sharing].nil? && (current_user.id = @post.id || current_user.admin || current_user.editor)
        @post.sharing = params[:sharing]
        @post.save
        @message = @post.sharing ? "Peer sharing is turned on!" : "Peer sharing is turned off."
        redirect_to @post, notice: @message
      end
      if (@post.sharing || @post.partner_id.present?) && !current_user.nil?
        @comment = current_user.comments.build(post_id: @post.id)
        @partner = User.find_by(id: @post.partner_id)
      end
      if !@post.is_published?
        @comments = @post.comments.where(comment_id: nil).order("created_at desc")
        if params[:comment_id].present?
          @comment_from_notifications = Comment.find(params[:comment_id]).id
          @comment_parent_from_notifications = Comment.find(params[:comment_id]).comment_id
        end
      else
        @trending = @post.category.posts.published.where(:publish_at => (Time.now - 2.months)..Time.now).order("post_impressions desc").limit(7)
      end
      set_meta_tags :title => @post.title,
                    :description => @post.meta_description,
                    :image => "https:" + @post.thumbnail.url(:large2),
                    :fb => {
                      :app_id => "1190455601051741"
                    },
                    :og => {
                      :url => "https://www.theteenmagazine.com/#{@post.slug}",
                      :type => "article",
                      :title => @post.title,
                      :description => @post.meta_description,
                      :image => {
                        :url => "https:" + @post.thumbnail.url(:large2),
                        :alt => @post.title,
                      },
                      :site_name => "The Teen Magazine",
                    },
                    :article => {
                      :publisher => "https://www.facebook.com/theteenmagazinee"
                    },
                    :twitter => {
                      :card => "summary_large_image",
                      :site => "@theteenmagazin_",
                      :title => @post.title,
                      :description => @post.meta_description,
                      :creator => @post.user.full_name,
                      :image => "https:" + @post.thumbnail.url(:large),
                      :domain => "https://www.theteenmagazine.com/"
                    }
    elsif current_user.present?
      redirect_to current_user, notice: "This draft does not have sharing turned on."
    else
      redirect_to new_user_session_path, notice: "You must sign in to continue."
      store_location_for(:user, request.fullpath)
    end
  end

  def unapprove
    @post = Post.unscoped.update(params[:approve], :approved => false)
    render :action => :success if @post.save
  end

  def edit
    @categories = Category.all
    @service_id = ENV['WEBSPELLCHECKER_ID']
    #create new review if no current review or last review was rejected
    @requested_changes = @post.reviews.where(status: "Rejected").last.try(:feedback_givens)
    @review = (@post.reviews.last.nil?) || (@post.reviews.last.try(:status).eql? "Rejected") ? @post.reviews.build(active: true, feedback_givens: @post.reviews.last.feedback_givens) : @post.reviews.last
    @feedbacks = Feedback.all
    @feedbacks_editor_frm = Feedback.active.left_joins(:feedback_givens).group(:id).order('COUNT(feedback_givens.id) DESC')
    set_meta_tags :title => "Edit Article"
  end

  def update
    @categories = Category.all
    @prev_review = @post.reviews.last.clone
    @prev_status = @post.reviews.last.status.clone
    if @post.update! post_params
      if (@post.content.include? "instagram.com/p/") && !(@post.content.include? "instgrm.Embeds.process()")
        @post.content << "<script async src='https://instagram.com/static/bundles/es6/EmbedSDK.js/47c7ec92d91e.js'></script>"
        @post.content << "<script>instgrm.Embeds.process()</script>"
      end
      @new_status = @post.reviews.last.status.clone
      @rev = @post.reviews.last
      if @new_status != "Approved for Publishing"
        @post.publish_at = nil
      end
      if ((@new_status.eql? "In Review") || ((@new_status.eql? "Rejected") && (@prev_status.eql? "In Review"))) && current_user.editor?
        @rev.update_column('editor_id', current_user.id)
        @rev.feedback_givens.each do |rev|
          rev.destroy
        end
        @feedback_given = post_params[:feedback_list]
        @feedback_given.try(:each) do |feedback_id|
          @feedback = Feedback.find(feedback_id)
          @critique = @feedback.feedback_givens.build(review_id: @rev.id)
          @critique.save
        end
      end
      if (@new_status.eql? "Approved for Publishing") && !(@prev_status.eql? "Approved for Publishing")
        if @post.user.posts.published.count.eql? 0
          ApplicationMailer.first_article_published(@post.user, @post).deliver
        else
          ApplicationMailer.article_published(@post.user, @post).deliver
        end
        @post.publish_at = Time.now
      end
      if @rev.present?
        @post.reviews.each do |review|
          review.update_column('active', false)
        end
        @rev.update_column('active', true)
      end
      fix_formatting
      @post.save
      if (@new_status.eql? "In Progress") && ((@prev_status.eql? "Ready for Review") || (@prev_status.eql? "In Review"))
        @notice = "Your article was withdrawn from review."
      elsif ((@prev_status.eql? "In Progress") || (@prev_status.blank?)) && (@new_status.eql? "Ready for Review")
        ApplicationMailer.article_moved_to_submitted(@post.user, @post).deliver
        @notice = "Great job! Your article was submitted for review."
      else
        @notice = "Your changes were saved."
      end
      if @new_status.eql? "Rejected"
        ApplicationMailer.article_has_requested_changes(@post.user, @post).deliver
      end
      if post_params[:promoting_until].present?
        @post.user.points = @post.user.points - 300
        @post.user.save
        redirect_to "/community", notice: "Your draft is now being promoted!"
      elsif (post_params[:partner_id].present? && post_params[:partner_id] != false)
        @partner = User.find(post_params[:partner_id])
        redirect_to @partner, notice: "This article was successfully shared with #{@partner.full_name}."
      elsif (@new_status.eql? "In Review") && (current_user.editor?)
        @notice = @prev_review.editor_id == current_user.id ? "Your changes were saved." : "Great job! You've claimed editing this article!"
        if !(@prev_status.eql? "In Review")
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

  def fix_formatting
    @post.title = @post.title.split.map{|s| s.slice(0,1).capitalize + s.slice(1..-1)}.join(' ')
    @post.title.gsub!(" A ", " a ")
    @post.title.gsub!(" Is ", " is ")
    @post.title.gsub!(" The ", " the ")
    @post.title.gsub!(" For ", " for ")
    @post.title.gsub!(" An ", " an ")
    @post.title.gsub!(" And ", " and ")
    @post.title.gsub!(" Nor ", " nor ")
    @post.title.gsub!(" Yet ", " yet ")
    @post.title.gsub!(" So ", " so ")
    @post.title.gsub!(" At ", " at ")
    @post.title.gsub!(" Around ", " around ")
    @post.title.gsub!(" But ", " but ")
    @post.title.gsub!(" By ", " by ")
    @post.title.gsub!(" After ", " after ")
    @post.title.gsub!(" Along ", " along ")
    @post.title.gsub!(" From ", " from ")
    @post.title.gsub!(" Of ", " of ")
    @post.title.gsub!(" On ", " on ")
    @post.title.gsub!(" To ", " to ")
    @post.title.gsub!(" With ", " with ")
    @post.title.gsub!(" In ", " in ")
    loop do
      if @post.content[/style="margin(.*?)"/m, 0].present?
        @post.content.gsub!(@post.content[/style="margin(.*?)"/m, 0], "")
      else
        break
      end
    end
    loop do
      if @post.content[/<b (.*?)>/m, 0].present?
        @post.content.gsub!(@post.content[/<b (.*?)>/m, 0], "")
      else
        break
      end
    end
    # loop do
    #   if @post.content[/<span(.*?)>/m, 0].present?
    #     @post.content.gsub!(@post.content[/<span(.*?)>/m, 0], "")
    #   else
    #     break
    #   end
    # end
    @post.content.gsub!('dir="ltr"', "")
    @post.content.gsub!("h1", "h2")
    @post.content.gsub!("&nbsp;", " ")
    @post.content.gsub!('<p> </p>', "")
    # @post.content.gsub!("</span>", "")
    @post.content.gsub!("<b>", "")
    @post.content.gsub!("</b>", "")
    @post.content.gsub!('<p><meta charset="utf-8" /></p>', "")
    @post.content.gsub!("<br />", "")
    @post.content.gsub!("<br>", "")
    @post.content.gsub!("<pre>", "<p>")
    @post.content.gsub!("</pre>", "</p>")
    @post.content.gsub!("<hr />", "")
    @post.content.gsub!("s3.amazonaws.com/media.theteenmagazine.com", "media.theteenmagazine.com")
    @post.content.gsub!("s3.amazonaws.com/theteenmagazine", "media.theteenmagazine.com")
  end

  def post_params
    params.require(:post).permit(:title, :featured, :editor_can_make_changes, :thumbnail, :ranking, :content, :image, :category_id, :partner_id, :post_impressions, :meta_description, :keywords, :user_id, :admin_id, :pitch_id, :waiting_for_approval, :approved, :sharing, :collaboration, :after_approved, :created_at, :publish_at, :promoting_until, :slug, :feedback_list => [], :reviews_attributes => [:id, :post_id, :created_at, :status, :notes])
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

  def is_admin?
    if (current_user && (current_user.admin? || current_user.editor?))
      true
    else
      redirect_to current_user, notice: "You do not have access to this page."
    end
  end

  def is_partner?
    if !current_user.partner
      true
    else
      redirect_to current_user, notice: "You do not have access to this page."
    end
  end

  def find_post
    begin
      @post = Post.friendly.find params[:id]
    rescue
      redirect_to root_path
    end
  end

  def set_layout
    if @post.nil?
      "minimal"
    elsif @post.is_published? && @review.nil?
      "application"
    else
      "minimal"
    end
  end
end
