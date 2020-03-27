class FeedbacksController < ApplicationController
  before_action :find_feedback, except: [:new, :create]
  before_action :is_admin?
  before_action :authenticate_user!
  load_and_authorize_resource

  def new
    @feedback = Feedback.new
  end

  def edit
  end

  def update
    if @feedback.update feedback_params
      @feedback.save
      redirect_to reviews_path, notice: "Your changes were saved."
    else
      render 'edit', notice: "Oops, something went wrong."
    end
  end

  def create
    if @feedback.save
      redirect_to reviews_path, notice: "Your feedback field was successfully added!"
    else
      render 'new', notice: "Oh no! Your changes were not able to be saved!"
    end
  end

  def is_admin?
    redirect_to root_path unless (current_user && (current_user.admin? || current_user.editor?))
  end

  private

  def feedback_params
    params.require(:feedback).permit(:id, :editor_descr, :review_descr)
  end

  def find_feedback
    @feedback = Feedback.find(params[:id])
  end
end