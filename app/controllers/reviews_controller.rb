class ReviewsController < ApplicationController
  before_action :is_admin?, only: [:index]
  before_action :find_review, only: [:update, :destroy]
  before_action :authenticate_user!
  load_and_authorize_resource
  layout "minimal"

  def index
    if current_user.admin?
      @all_reviews = Post.all.in_review.order("updated_at desc")
    end
    @editors_reviews = Post.all.in_review.where(:reviews => {editor_id: current_user.id}).order("updated_at desc")
    @submitted_for_review = Post.all.submitted.order("updated_at desc")
    @submitted_pitches = Pitch.is_submitted.order("updated_at desc")
  end

  def update
    @review.update(review_params)
  end

  #only allow admin and editors to see reviews
  def is_admin?
    redirect_to root_path unless (current_user && (current_user.admin? || current_user.editor?))
  end

  private

  def review_params
    params.require(:review).permit(:created_at, :updated_at, :status, :post_id, :editor_id, :active, :notes)
  end

  def find_review
    @review = Review.find(params[:id])
  end
end
