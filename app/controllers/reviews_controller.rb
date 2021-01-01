class ReviewsController < ApplicationController
  before_action :find_review, only: [:update, :destroy]
  before_action :authenticate_user!
  load_and_authorize_resource
  layout "minimal"

  def index
    if params[:post].present?
      @post = Post.friendly.find(params[:post])
      set_meta_tags :title => "Editor Feedback for #{@post.title}"
    elsif (current_user.admin?) || (current_user.editor?)
      @user = User.find(params[:id])
      if (params[:completed_onboarding].eql? "true") && current_user.completed_editor_onboarding.nil?
        @show_editor_dashboard_onboarding = true
        flash.now[:notice] = "You've unlocked your editor dashboard!"
        @user.completed_editor_onboarding = true
        @user.save
      elsif current_user.completed_editor_onboarding.nil?
        redirect_to "/editor-onboarding", notice: "Please complete the onboarding process first."
      end
      if !(params[:id].eql? current_user.slug) && !current_user.admin
        redirect_to "/editors/#{current_user.slug}", notice: "You do not have access to that page."
      end
      @notifications = @notifications - @unseen_editor_dashboard_cnt
      @unseen_editor_dashboard_cnt = 0
      @reviews_requirement = Integer(Constant.find_by(name: "# of monthly reviews editors need to complete").try(:value) || '0')
      @pitches_requirement = Integer(Constant.find_by(name: "# of monthly pitches editors need to complete").try(:value) || '0')
      @max_reviews = Integer(Constant.find_by(name: "max # of reviews per month for editors").try(:value) || '0')
      @editor_pitches_cnt =  @user.pitches.where("created_at > ?", Date.today.beginning_of_month).count
      @editor_reviews_cnt = Review.where(editor_id: @user.id).where("updated_at > ?", Date.today.beginning_of_month).count
      @editors_reviews = Post.all.in_review.where(:reviews => {editor_id: @user.id}).order("updated_at desc")
      @submitted_for_review = Post.all.submitted.order("updated_at desc")
      @submitted_pitches = Pitch.is_submitted.order("updated_at desc")
      if (params[:id].eql? current_user.slug)
        Thread.new do
          current_user.update_column('last_saw_editor_dashboard', Time.now)
        end
      end
      set_meta_tags :title => "Edit | The Teen Magazine"
    else
      redirect_to user_path(current_user), notice: "You are not allowed access to the editor reviews."
    end
  end

  def get_editor_activity
    @update_since = Activity.first.try(:action_at) || Time.now - 30.days
    @editor_reviewed_article = Review.where.not(editor_id: nil).where("updated_at > ?", @update_since)
    @editor_reviewed_pitch = Pitch.where(claimed_id: nil).where.not(status: nil, editor_id: nil).where("updated_at > ?", @update_since)
    @editor_pitched_new_article = Pitch.is_approved.not_claimed.where(status: nil).where("created_at > ?", @update_since)

    @editor_reviewed_article.each do |review|
      @post = Post.find_by(id: review.post_id)
      if @post.present?
        if review.status.eql? "Rejected"
          @action = "<b>Rejected</b> <a target='_blank' href='/#{@post.slug}/edit'>#{@post.try(:title)}</a>"
        elsif review.status.eql? "Approved for Publishing"
          @action = "<b>Published</b> the article <a target='_blank' href='/#{@post.slug}'>#{@post.try(:title)}</a>"
        else
          @action = "moved the article <a target='_blank' href='/#{@post.slug}'>#{@post.try(:title)}</a> to <b>#{review.status}</b></a>"
        end
        @activity_does_not_exist = Activity.where(action: @action, kind: review.class.name, kind_id: review.id, user_id: review.editor_id).count.eql? 0
        if @activity_does_not_exist
          Activity.create(action: @action, action_at: review.updated_at, kind: review.class.name, kind_id: review.id, user_id: review.editor_id)
        end
      end
    end
    @editor_reviewed_pitch.each do |pitch|
      Activity.create(action: "changed the status of the pitch <a target='_blank' href='/pitches/#{pitch.slug}'>#{pitch.try(:title)}</a> to <b>#{pitch.try(:status)}</b>", action_at: pitch.updated_at, kind: pitch.class.name, kind_id: pitch.id, user_id: pitch.editor_id)
    end
    @editor_pitched_new_article.each do |pitch|
      Activity.create(action: "pitched <a target='_blank' href='/pitches/#{pitch.slug}'>#{pitch.try(:title)}</a>", action_at: pitch.created_at, kind: pitch.class.name, kind_id: pitch.id, user_id: pitch.user_id)
    end
    @per_page = 20
    @last_page = Activity.all.count / @per_page
    @page = params[:page].nil? ? 1 : Integer(params[:page]) + 1
    @pagy, @editor_activity = pagy_countless(Activity.all, page: params[:page], items: @per_page, link_extra: 'data-remote="true"')
    if params[:page].present?
      respond_to do |format|
        format.js
      end
    else
      render partial: "reviews/all_editor_activity"
    end
  end

  def update
    @review.update(review_params)
  end

  def enable_notify_of_new_review
    @user = User.find(params[:user_id])
    @user.notify_of_new_review = true
    @user.save
    redirect_to "/editors/#{@user.slug}", notice: "Notifications turned on."
  end

  def disable_notify_of_new_review
    @user = User.find(params[:user_id])
    @user.notify_of_new_review = false
    @user.save
    redirect_to "/editors/#{@user.slug}", notice: "Notifications turned off."
  end

  def destroy
    @post = @review.post
    @review.destroy
    if !@post.reviews.exists?
      @rev = @post.reviews.build(active: true, status: "In Progress")
      @rev.save
    end
    redirect_to post_path(@post), notice: "The review was successfully deleted."
  end

  private

  def review_params
    params.require(:review).permit(:created_at, :updated_at, :editor_claimed_review_at, :status, :post_id, :editor_id, :active, :notes)
  end

  def find_review
    @review = Review.find(params[:id])
  end
end
