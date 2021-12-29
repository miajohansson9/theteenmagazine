class FeedbacksController < ApplicationController
  before_action :find_feedback, except: %i[new create index]
  before_action :is_admin?
  before_action :authenticate_user!
  load_and_authorize_resource

  def new
    @feedback = Feedback.new
    set_meta_tags title: 'New Feedback Field'
  end

  def edit
    set_meta_tags title: 'Edit Feedback Field'
  end

  def index
    @feedbacks = Feedback.active.order('created_at asc')
    @feedbacks_given = FeedbackGiven.all
    set_meta_tags title: 'Editor Feedback Fields'
  end

  def update
    if @feedback.update feedback_params
      @feedback.save
      redirect_to feedbacks_path, notice: 'Your changes were saved.'
    else
      render 'edit', notice: 'Oops, something went wrong.'
    end
  end

  def create
    if @feedback.save
      redirect_to feedbacks_path,
                  notice: 'Your feedback field was successfully added!'
    else
      render 'new', notice: 'Oh no! Your changes were not able to be saved!'
    end
  end

  def is_admin?
    unless (current_user && (current_user.admin? || current_user.editor?))
      redirect_to root_path
    end
  end

  private

  def feedback_params
    params
      .require(:feedback)
      .permit(:id, :editor_descr, :review_descr, :archive)
  end

  def find_feedback
    @feedback = Feedback.find(params[:id])
  end
end
