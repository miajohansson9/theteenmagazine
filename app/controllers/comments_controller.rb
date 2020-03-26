class CommentsController < ApplicationController
  before_action :find_comment, except: [:create]

  def destroy
    @comment.destroy
    redirect_to :back
  end

  def create
    @comment = current_user.comments.build(comment_params)
    @comment.save
    redirect_to :back
  end

  private

  def find_comment
    @comment = Comment.find(params[:id])
  end

  def comment_params
    params.require(:comment).permit(:created_at, :id, :text, :user_id, :post_id)
  end
end
