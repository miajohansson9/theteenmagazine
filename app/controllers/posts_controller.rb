class PostsController < ApplicationController
  before_action :find_post_history, only: [:show]
  before_action :find_post, only: %i[edit update destroy update_newsletter generate_shareable_token]
  before_action :get_headers, only: [:show, :draft]
  before_action :authenticate_user!,
                except: %i[
                  show
                  get_recent_posts_in_category
                  subscribe
                  is_email
                  get_promoted_posts
                  get_comments_published
                ]
  before_action :load_author, only: [:show]
  before_action :create, only: [:unapprove]
  before_action :is_admin?, only: [:new]
  before_action :is_partner?, only: %i[index edit]
  after_action :log_impression, only: [:show]
  load_and_authorize_resource except: %i[
                                get_recent_posts_in_category
                                get_conversations_following
                                subscribe
                                is_email
                                get_promoted_posts
                                get_comments_published
                                generate_shareable_token
                              ]

  def log_impression
    # check if post is published
    if @post.is_published? && !browser.bot?
      # don't count views on own articles
      if !(user_signed_in? && ((@post.user.id == current_user.id) || (current_user.full_name == @post.collaboration)))
        # don't count refreshes
        if !(session[:has_counted_view].eql? @post.id)
          if @post.post_impressions.nil?
            new_impressions = 1
          else
            new_impressions = @post.post_impressions + 1
          end
          @post.update_attribute(:post_impressions, new_impressions)
          # calculate new trending score
          @hours = [24.0, ((Time.now - @post.publish_at) / 1.hour).round].max
          @points = @post.post_impressions.to_f
          score = (@points / ((@hours+2.0)**1.8)) * 1000.0
          # update new trending score
          @post.update_attribute(:trending_score, score)
          # create session variable to not log again
          session[:has_counted_view] = @post.id
        end
      end
    end
  end

  def index
    set_meta_tags title: "Community | The Teen Magazine"
    @user = current_user
    @notifications = @unseen_shared_drafts_cnt - @unseen_shared_drafts_cnt
    @unseen_shared_drafts_cnt = 0
    if current_user.points.nil?
      current_user.points = 0
      current_user.save
    end
    @points = current_user.points
    @my_shared_drafts =
      Post
        .where("collaboration like ?", "%#{current_user.email}%")
        .or(Post.where(user_id: current_user.id))
        .where(sharing: true, publish_at: nil)
        .draft
        .order("updated_at desc")
    @pagy, @shared_drafts =
      pagy(
        Post.where(sharing: true).draft.order(:shared_at).reverse_order,
        page: params[:page],
        items: 12,
      )
    Thread.new { current_user.update_column("last_saw_community", Time.now) }
  end

  def new
    @categories = Category.active
    @service_id = ENV["WEBSPELLCHECKER_ID"]
    @post = current_user.posts.build
    @review = @post.reviews.build(status: "In Progress", active: true)
    set_meta_tags title: "Edit Article", editing: "Turn off ads"
  end

  def create
    @categories = Category.active
    @post = current_user.posts.build(post_params)
    @prev_post_pitch =
      current_user.posts.find_by(pitch_id: post_params[:pitch_id])
    if !(@prev_post_pitch.try(:pitch).nil?)
      if @prev_post_pitch.can_reclaim_pitch?
        @prev_post_pitch.reviews.destroy
        @rev =
          @prev_post_pitch.reviews.build(status: "In Progress", active: true)
        @rev.save
        @post.pitch.update_columns(
          { claimed_id: current_user.id, claimed_at: Time.now }
        )
        @prev_post_pitch.update_column(
          :title,
          Pitch.find(post_params[:pitch_id]).title
        )
        if @prev_post_pitch.deadline_at.nil? && @post.pitch.deadline.present?
          @prev_post_pitch.update_column(
            :deadline_at,
            Time.now + (@post.pitch.deadline).weeks
          )
        end
        redirect_to @prev_post_pitch, notice: "You've reclaimed this pitch!"
      else
        redirect_to @prev_post_pitch.pitch,
                    notice: "Oops you've missed the deadline for this pitch previously."
      end
    else
      fix_formatting
      if (@post.content.include? "instagram.com/p/") &&
         !(@post.content.include? "instgrm.Embeds.process()")
        @post.content =
          @post.content << "<script>instgrm.Embeds.process()</script>"
      end
      if @post.save && @post.is_published?
        redirect_to @post,
                    notice: "Congrats! Your post was successfully published on The Teen Magazine!"
      elsif @post.save && !@post.pitch.nil? && @post.pitch.claimed_id.nil?
        claim_pitch
        redirect_to @post, notice: "You've claimed this pitch!"
      elsif @post.save
        redirect_to @post, notice: "Changes were successfully saved!"
      else
        render "new", notice: "Oh no! Your post was not able to be saved!"
      end
    end
  end

  def claim_pitch
    @post.pitch.update(
      claimed_id: current_user.id,
      claimed_at: Time.now,
    )
    if @post.pitch.deadline.present?
      @post.update(
        "deadline_at" => Time.now + (@post.pitch.deadline).weeks,
      )
    end
    @rev = @post.reviews.build(status: "In Progress", active: true)
    @rev.save
    Thread.new do
      @post.thumbnail.attach(@post.pitch.thumbnail.blob)
    end
  end

  def get_headers
    @date = @post.is_published? ? @post.publish_at : @post.created_at
    if @post.thumbnail_credits.present?
      @thumbanil_credits =
        (@post.thumbnail_credits.include? ",") ? @post.thumbnail_credits.split(",") : [@post.thumbnail_credits.upcase]
    end
    if @post.partner_id && @post.show_disclosure
      @partner = User.find_by(id: @post.partner_id)
      @partner_name = @partner ? @partner&.full_name&.upcase&.truncate(25) : nil
    end
  end

  def show
    cookies[:fetched_at] = Time.now
    if @post.is_published?
      published
    elsif current_user.present? || (params[:shareable_token] == @post.shareable_token)
      draft
    else
      redirect_to new_user_session_path, notice: "You must sign in to continue."
      store_location_for(:user, request.fullpath)
    end
  end

  def published
    @collabs = []
    if @post.collaboration.present?
      @emails = @post.collaboration.delete(" ").split(",")
      @emails.each do |email|
        @writer = User.where(email: email).first
        @collabs.push @writer if @writer.present?
      end
    end
    if !current_user.nil?
      @comment = current_user.comments.build(post_id: @post.id)
    else
      @comment = Comment.new(post_id: @post.id)
    end
    set_post_meta_tags
  end

  def get_header_image
    render partial: "posts/partials/header_image", locals: { user: @user, post: @post, comments: @comments, comment: @comment }
  end

  def get_comments_published
    @user = User.find(params[:user_id])
    @post = Post.find(params[:post_id])
    if !current_user.nil?
      @comment = current_user.comments.build(post_id: @post.id)
    else
      @comment = Comment.new(post_id: @post.id)
    end
    @comments = @post.comments.where(comment_id: nil, public: true).order("created_at desc")
    if params[:comment_id].present?
      @comment_from_notifications = Comment.find(params[:comment_id]).id
      @comment_parent_from_notifications =
        Comment.find(params[:comment_id]).comment_id
    end
    render partial: "posts/partials/comments_published", locals: { user: @user, post: @post, comments: @comments, comment: @comment }
  end

  def draft
    @date = @post.created_at
    if (params[:shareable_token] == @post.shareable_token) ||
       (current_user &&
        (@post.sharing || @post.user_id == current_user.id ||
         @post.partner_id == current_user.id ||
         (@post.collaboration&.include? current_user.email) ||
         current_user.admin? || current_user.editor?))
      @collabs = []
      if @post.collaboration.present?
        @emails = @post.collaboration.delete(" ").split(",")
        @emails.each do |email|
          @writer = User.where(email: email).first
          @collabs.push @writer if @writer.present?
        end
      end
      if params[:partner].present?
        @post.partner_id = nil
        @post.sharing = false
        @post.save
        redirect_to @post, notice: "Partner sharing turned off for this article"
      elsif !params[:sharing].nil? &&
            (current_user.id =
              @post.id || current_user.admin || current_user.editor)
        @post.sharing = params[:sharing]
        @post.shared_at = params[:sharing] ? Time.now : nil
        @post.save
        @message = if @post.sharing
            "Peer sharing is turned on!"
          else
            "Peer sharing is turned off."
          end
        redirect_to @post, notice: @message
      end
      if (@post.sharing || @post.partner_id.present?) && !current_user.nil?
        @comment = current_user.comments.build(post_id: @post.id)
        @partner = User.find_by(id: @post.partner_id)
      end
      @comments = @post.comments.where(comment_id: nil).order("created_at desc")
      if params[:comment_id].present?
        @comment_from_notifications = Comment.find(params[:comment_id]).id
        @comment_parent_from_notifications =
          Comment.find(params[:comment_id]).comment_id
      end
      set_post_meta_tags
    elsif current_user.present?
      redirect_to current_user,
                  notice: "This draft does not have sharing turned on."
    else
      redirect_to new_user_session_path, notice: "You must sign in to continue."
      store_location_for(:user, request.fullpath)
    end
  end

  def generate_shareable_token
    @shareable_token = SecureRandom.urlsafe_base64
    @post.update_column("shareable_token", @shareable_token)
    redirect_to @post, notice: "You've generated a shareable link!"
  end

  def get_promoted_posts
    @per_page = 9
    @fetched_at = cookies[:fetched_at].present? ? cookies[:fetched_at] : Time.now
    @posts_promoted_records = Post.published.where(updated_at: (Time.now - 1.days)..@fetched_at).where.not(id: params[:post_id]).by_updated.limit(54)
    @page = params[:page].nil? ? 2 : Integer(params[:page]) + 1
    @is_last_page =
      (@posts_promoted_records.count - (@page - 2) * @per_page) <= @per_page
    @pagy, @posts_promoted =
      pagy_countless(
        @posts_promoted_records,
        page: params[:page],
        items: @per_page,
        link_extra: 'data-remote="true"',
      )
    if params[:page].present?
      respond_to { |format| format.js }
    else
      render partial: "posts/partials/promoted/all_promoted_articles"
    end
  end

  def get_recent_posts_in_category
    @post = Post.find(params[:id])
    @recent = @post.category.posts.published.by_published_date.where.not(id: @post.id).limit(3)
    render partial: "posts/partials/recent"
  end

  def get_conversations_following
    @replies =
      current_user
        .comments
        .map { |c| c.comments.where.not(user_id: current_user.id) }
        .flatten
        .reject(&:blank?)
    @comments_following =
      current_user
        .comments
        .where.not(comment_id: nil)
        .map do |c|
        @parent = Comment.find_by(id: c.comment_id)
        if @parent.try(:comments).present?
          @parent.comments.where("created_at > ?", c.created_at)
        end
      end
        .flatten
        .reject(&:blank?)
        .delete_if { |c| c.user_id.eql? current_user.id }
    @post_comments =
      current_user
        .posts
        .draft
        .map { |p| p.comments.where.not(user_id: current_user.id) }
        .flatten
    @all =
      (@comments_following + @post_comments + @replies)
        .uniq
        .sort_by(&:created_at)
        .reverse
        .take(20)
    render partial: "posts/community/conversations_following"
  end

  def subscribe
    @failed = true
    begin
      if isEmail(params[:posts][:email])
        # subscribe to TTM newsletter
        maybe_subscriber = Subscriber.find_by('lower(email) = ?', params[:posts][:email].downcase)
        if !maybe_subscriber.present?
          @token = SecureRandom.urlsafe_base64
          subscriber = Subscriber.new(
              email: params[:posts][:email], 
              token: @token,
              source: "Subscribe widget",
              opted_in_at: Time.now,
              subscribed_to_reader_newsletter: true,
              subscribed_to_writer_newsletter: false,
          )
          subscriber.save
        else
          maybe_subscriber.update_column("subscribed_to_reader_newsletter", true)
        end
        @failed = false
      else
        redirect_to "/subscribe", notice: "Please enter a valid email address."
      end
    rescue => error
      puts error
    end
    respond_to { |format| format.js }
  end

  def isEmail(str)
    return str.match(/\A[\w+\-.]+@[a-z\d\-]+(\.[a-z\d\-]+)*\.[a-z]+\z/i)
  end

  def unapprove
    @post = Post.unscoped.update(params[:approve], approved: false)
    render action: :success if @post.save
  end

  def edit
    if @post.is_locked?
      redirect_to @post, notice: "You can no longer work on this article."
      return
    end
    @can_edit =
      !(@post.reviews.last.try(:status).eql? "Approved for Publishing") ||
        (current_user.id == @post.user_id) ||
        (@post.collaboration&.include? current_user.email) ||
        (current_user.admin?) ||
        (@post.reviews.last.editor_id.eql? current_user.id)
    @categories = Category.active.or(Category.where(id: @post.category_id))
    @service_id = ENV["WEBSPELLCHECKER_ID"]

    #create new review if no current review or last review was rejected
    @requested_changes =
      @post.reviews.where(status: "Rejected").last.try(:feedback_givens)

    #create a new review if the last review is either nil or rejected
    if (@post.reviews.last.nil?) ||
       (@post.reviews.last.try(:status).eql? "Rejected")
      @review =
        @post.reviews.build(
          active: true,
          feedback_givens: @post.reviews.last.try(:feedback_givens),
        )
      #create a new review for an already published article that is updated by a different editor
    elsif (@post.reviews.last.try(:status).eql? "Approved for Publishing") &&
          !(@post.reviews.last.try(:editor_id).eql? current_user.id) &&
          (current_user.id != @post.user_id)
      @review =
        @post.reviews.build(
          active: true,
          status: "Approved for Publishing",
          editor_id: current_user.id,
        )
    else
      @review = @post.reviews.last
    end
    @reviews =
      @post.reviews.where(status: ["Rejected", "Approved for Publishing"])
    @feedbacks = Feedback.all
    @feedbacks_editor_frm = Feedback.active.order("created_at asc")
    @editor_options = if ((@post.reviews.last.status.eql? "In Review") ||
                          (@post.reviews.last.status.eql? "Approved for Publishing"))
        ["Ready for Review", "In Review", "Rejected", "Approved for Publishing"]
      else
        ["In Progress", "Ready for Review", "In Review"]
      end
    @statuses = if current_user.editor?
        @editor_options
      else
        ["In Progress", "Ready for Review"]
      end
    @should_show_editor_form =
      (current_user.id == @post.reviews.last.editor_id) &&
        (@post.reviews.last.try(:status).eql? "In Review")
    @reviews_rejected = @post.reviews.where(status: "Rejected")
    if !(current_user.editor?) &&
       !(@statuses.include? @post.reviews.last.status)
      @statuses << @post.reviews.last.status
    end
    set_meta_tags title: "Edit Article", editing: "Turn off ads"
  end

  def update_newsletter
    @newsletter_id = if post_params[:newsletter_id].present?
        post_params[:newsletter_id]
      else
        @post.newsletter_id
      end
    if @post.update post_params
      @message = if post_params[:newsletter_id].present?
          "Article added to newsletter."
        else
          "Article removed from newsletter."
        end
      redirect_to "/newsletters/#{@newsletter_id}/featured-posts",
                  notice: @message
    end
  end

  def update
    @categories = Category.all
    @prev_review = @post.reviews.last.clone
    @prev_status = @post.reviews.last.status.clone
    @prev_featured = @post.featured.clone
    if post_params[:thumbnail].present?
      @post.thumbnail.attach(post_params[:thumbnail])
    end
    if @post.update post_params
      if (@post.content.include? "instagram.com/p/") &&
         !(@post.content.include? "instgrm.Embeds.process()")
        @post.content <<
          "<script async src='https://instagram.com/static/bundles/es6/EmbedSDK.js/47c7ec92d91e.js'></script>"
        @post.content << "<script>instgrm.Embeds.process()</script>"
      end
      if (@prev_featured == false || @prev_featured.nil?) &&
         (current_user.admin) && (post_params[:featured].eql? "1")
        ApplicationMailer.featured_article(@post.user, @post).deliver
        @prev = Post.published.where.not(id: @post.id).where(featured: true)
        @prev.each do |pst|
          pst.featured = false
          pst.save
        end
      end
      @new_status = @post.reviews.last.status.clone
      @rev = @post.reviews.last
      @post.publish_at = nil if @new_status != "Approved for Publishing"
      if ((@new_status.eql? "In Review") ||
          ((@new_status.eql? "Rejected") && (@prev_status.eql? "In Review"))) && current_user.editor?
        @rev.update_column("editor_id", current_user.id)
        @rev.feedback_givens.each { |rev| rev.destroy }
        @feedback_given = post_params[:feedback_list]
        @feedback_given.try(:each) do |feedback_id|
          @feedback = Feedback.find(feedback_id)
          @critique = @feedback.feedback_givens.build(review_id: @rev.id)
          @critique.save
        end
      end
      if (@new_status.eql? "Approved for Publishing") &&
         !(@prev_status.eql? "Approved for Publishing")
        if !@post.thumbnail.attached?
          # post does not have thumbnail! this will break the homepage
          redirect_to edit_post_path(@post), notice: "This post does not have a thumbnail image! It cannot be published"
          @rev.update_column(:status, "In Review")
          return
        end
        if !@post.agree_to_image_policy
          redirect_to edit_post_path(@post), notice: "The writer has not agreed to the image policy! It cannot be published"
          @rev.update_column(:status, "In Review")
          return
        end
        if @post.user.posts.published.count.eql? 0
          ApplicationMailer.first_article_published(@post.user, @post).deliver
        else
          ApplicationMailer.article_published(@post.user, @post).deliver
        end
        if @post.is_interview? && @post.pitch&.contact_email.present?
          ApplicationMailer.interview_published(@post).deliver
        end
        @post.promoting_until = nil
        @post.update_column("publish_at", Time.now)
      end
      if @rev.present?
        @post.reviews.each { |review| review.update_column("active", false) }
        @rev.update_column("active", true)
      end
      fix_formatting
      @post.save!
      if (@new_status.eql? "In Progress") &&
         ((@prev_status.eql? "Ready for Review") ||
          (@prev_status.eql? "In Review"))
        @notice = "Your article was withdrawn from review."
      elsif ([nil, "In Progress", "Rejected"].include? @prev_status) &&
            (@new_status.eql? "Ready for Review")
        if !@post.thumbnail.attached?
          # post does not have thumbnail! this can break the homepage
          redirect_to edit_post_path(@post), notice: "This post does not have a thumbnail image! It cannot be submitted for review."
          @rev.update_column(:status, "In Progress")
          return
        end
        if !@post.agree_to_image_policy
          redirect_to edit_post_path(@post), notice: "You have not agreed to the image policy! It cannot be submitted for review."
          @rev.update_column(:status, "In Progress")
          return
        end
        if @post.reviews.count > 1
          begin
            # has been reviewed before and should go to the previous reviewer
            @reviews = @post.reviews.where.not(editor_id: nil).order("created_at asc")
            @prev_editor = User.find(@reviews.last.editor_id)
            @notice = "Great job! #{@prev_editor.full_name} was assigned this review."
            @rev.update_columns({
              status: "In Review",
              editor_id: @prev_editor.id, 
              editor_claimed_review_at: Time.now,
            })
            ApplicationMailer.article_moved_to_review(@post.user, @post, @prev_editor).deliver
            ApplicationMailer.editor_assigned_review(@prev_editor, @post).deliver
            Sentry.capture_message("re-assigned editor to review for post #{@post.slug} successfully")
          rescue => e
            Sentry.capture_message(e)
            Sentry.capture_message("did not re-assign editor to review for post #{@post.slug}")
            deliver_submitted_article_emails
            @notice = "Great job! Your article was submitted for review."
          end
        else
          deliver_submitted_article_emails
          @notice = "Great job! Your article was submitted for review."
        end
      else
        @notice = "Your changes were saved."
      end
      if @new_status.eql? "Rejected"
        if @post.deadline_at.present?
          @new_deadline = if @post.reviews.last.updated_at > @post.deadline_at
              @post.reviews.last.updated_at + 7.days
            else
              @post.deadline_at + 7.days
            end
          @post.update_column("deadline_at", @new_deadline)
        end
        ApplicationMailer.article_has_requested_changes(@post.user, @post)
          .deliver
      end
      if post_params[:promoting_until].present?
        @post.user.update_column("points", @post.user.points - 200)
        @post.update_column("shared_at", Time.now)
        redirect_to "/community", notice: "Your draft is now being promoted!"
      elsif post_params[:deadline_at].present?
        redirect_to "/writers/#{@post.user.slug}/extensions",
                    notice: "Extension applied."
      elsif (post_params[:partner_id].present? &&
             post_params[:partner_id] != false)
        @partner = User.find(post_params[:partner_id])
        redirect_to @partner,
                    notice: "This article was successfully shared with #{@partner.full_name}."
      elsif (@new_status.eql? "In Review") && (current_user.editor?)
        @notice = if (@prev_review.editor_id == current_user.id)
            "Your changes were saved."
          else
            "Great job, You've claimed editing this article!"
          end
        editor_claimed_review if !(@prev_status.eql? "In Review")
        redirect_to "/editors/#{current_user.slug}", notice: @notice
      else
        redirect_to @post, notice: @notice
      end
    else
      edit
      render "edit", notice: "Oh no! Your post was not able to be saved!"
    end
  end

  def editor_claimed_review
    @rev = @post.reviews.last
    @editor = User.find(@rev.editor_id)
    @rev.update_column("editor_claimed_review_at", Time.now)
    Thread.new do
      ApplicationMailer.article_moved_to_review(@post.user, @post, @editor).deliver
    end
  end

  def deliver_submitted_article_emails
    Thread.new do
      ApplicationMailer.article_moved_to_submitted(@post.user, @post).deliver
      Thread.new do
        if !@post.user.editor
          @editors_to_notify_of_new_review =
            User.where(editor: true, notify_of_new_review: true)
          @editors_to_notify_of_new_review.each do |editor|
            @editor_reviews_cnt =
              Review
                .where(editor_id: editor.id)
                .where("updated_at > ?", Date.today.beginning_of_month)
                .count
            @reviews_requirement =
              Integer(
                Constant
                  .find_by(
                    name: "# of monthly reviews editors need to complete",
                  )
                  .try(:value) || "0"
              )
            if @editor_reviews_cnt < @reviews_requirement
              ApplicationMailer.notify_editor_that_article_moved_to_review(
                editor,
                @post
              ).deliver
            end
          end
        end
      end
    end
  end

  def destroy
    if !@post.pitch.nil?
      if @post.pitch.claimed_id.eql? @post.user.id
        @post.pitch.update_column("claimed_id", nil)
      end
    end
    @post.destroy
    redirect_to current_user, notice: "Your article was deleted."
  end

  private

  def set_post_meta_tags
    set_meta_tags title: @post.title,
                  description: @post.meta_description,
                  image: @post.thumbnail,
                  fb: {
                    app_id: "1190455601051741",
                  },
                  og: {
                    url: "https://www.theteenmagazine.com/#{@post.slug}",
                    type: "article",
                    title: @post.title,
                    description: @post.meta_description,
                    image: {
                      url: @post.thumbnail,
                      alt: @post.title,
                    },
                    site_name: "The Teen Magazine",
                  },
                  article: {
                    publisher: "https://www.facebook.com/theteenmagazinee",
                  },
                  twitter: {
                    card: "summary_large_image",
                    site: "@theteenmagazin_",
                    title: @post.title,
                    description: @post.meta_description,
                    creator: @post.user.full_name,
                    image: @post.thumbnail,
                    domain: "https://www.theteenmagazine.com/",
                  }
  end

  def fix_formatting
    loop do
      if @post.content[/style="line-height(.*?)"/m, 0].present?
        @post.content.gsub!(@post.content[/style="line-height(.*?)"/m, 0], "")
      else
        break
      end
    end
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
    loop do
      if @post.content[/<span(.*?)>/m, 0].present?
        @post.content.gsub!(@post.content[/<span(.*?)>/m, 0], "")
      else
        break
      end
    end
    @post.content.gsub!('dir="ltr"', "")
    @post.content.gsub!("h1", "h2")
    @post.content.gsub!("&nbsp;", " ")
    @post.content.gsub!("<p> </p>", "")
    @post.content.gsub!("</span>", "")
    @post.content.gsub!("<b>", "")
    @post.content.gsub!("</b>", "")
    @post.content.gsub!('<p><meta charset="utf-8" /></p>', "")
    @post.content.gsub!("<br />", "")
    @post.content.gsub!("<br>", "")
    @post.content.gsub!("<pre>", "<p>")
    @post.content.gsub!("</pre>", "</p>")
    @post.content.gsub!("<div", "<p")
    @post.content.gsub!("</div>", "</p>")
    @post.content.gsub!("<address", "<p")
    @post.content.gsub!("</address>", "</p>")
    @post.content.gsub!("<hr />", "")
    @post.content.gsub!(
      "<p><iframe",
      "<p class='responsive-iframe-container'><iframe class='responsive-iframe'"
    )
    @post.content.gsub!(
      "s3.amazonaws.com/media.theteenmagazine.com",
      "media.theteenmagazine.com"
    )
    @post.content.gsub!(
      "s3.amazonaws.com/theteenmagazine",
      "media.theteenmagazine.com"
    )
    if !(@post.turn_off_caps)
      @post.title =
        @post
          .title
          .split
          .map { |s| s.slice(0, 1).capitalize + s.slice(1..-1) }
          .join(" ")
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
    end
  end

  def post_params
    params
      .require(:post)
      .permit(
        :title,
        :featured,
        :newsletter_id,
        :editor_can_make_changes,
        :thumbnail,
        :ranking,
        :content,
        :image,
        :category_id,
        :partner_id,
        :post_impressions,
        :meta_description,
        :keywords,
        :user_id,
        :admin_id,
        :pitch_id,
        :waiting_for_approval,
        :approved,
        :sharing,
        :collaboration,
        :after_approved,
        :created_at,
        :publish_at,
        :deadline_at,
        :shared_at,
        :promoting_until,
        :slug,
        :turn_off_caps,
        :thumbnail_credits,
        :show_disclosure,
        :trending_score,
        :shareable_token,
        :comments_turned_off,
        :agree_to_image_policy,
        :rank,
        feedback_list: [],
        reviews_attributes: %i[id post_id editor_id created_at status notes],
        user_attributes: %i[extensions id],
      )
  end

  def find_post_history
    begin
      @post = Post.friendly.find params[:id]
      if request.path != post_path(@post)
        return redirect_to @post, status: :moved_permanently
      end
    rescue StandardError
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
    rescue StandardError
      redirect_to root_path
    end
  end

  def load_author
    @user = @post.user if @post.user != nil
  end
end
