class CommentsController < ApplicationController
  before_action :find_comment, except: [:create]

  def destroy
    @comment.destroy
    redirect_to :back
  end

  def create
    @comment = current_user.comments.build(comment_params)
    @comment.save
    if current_user.id != @comment.post.user.id
      ApplicationMailer.comment_added(@comment.post.user, @comment.post).deliver
    end
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
