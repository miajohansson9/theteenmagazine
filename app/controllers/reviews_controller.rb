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
        redirect_to "/editors/#{current_user.slug}"
      end
      @notifications = @notifications - @unseen_editor_dashboard_cnt
      @unseen_editor_dashboard_cnt = 0
      if current_user.admin?
        @all_reviews = Post.all.in_review.order("updated_at desc")
      end
      @editor_pitches_cnt =  @user.pitches.where("created_at > ?", Date.today.beginning_of_month).count
      @editor_reviews_cnt = Review.where(editor_id: @user.id).where("created_at > ?", Date.today.beginning_of_month).count
      @editors_reviews = Post.all.in_review.where(:reviews => {editor_id: @user.id}).order("updated_at desc")
      @submitted_for_review = Post.all.submitted.order("updated_at desc")
      @submitted_pitches = Pitch.is_submitted.order("updated_at desc")
      if (params[:id].eql? current_user.slug)
        current_user.last_saw_editor_dashboard = Time.now
        current_user.save
      end
      set_meta_tags :title => "Edit | The Teen Magazine"
    else
      redirect_to user_path(current_user), notice: "You are not allowed access to the editor reviews."
    end
  end

  def update
    @review.update(review_params)
  end

  def destroy
    @review.destroy
    redirect_to :back, notice: "The review was successfully deleted."
  end

  private

  def review_params
    params.require(:review).permit(:created_at, :updated_at, :status, :post_id, :editor_id, :active, :notes)
  end

  def find_review
    @review = Review.find(params[:id])
  end
end
