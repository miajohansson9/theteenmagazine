class CommentsController < ApplicationController
  before_action :find_comment, only: [:destroy]

  def destroy
    @post = @comment.post
    if @comment.destroy
      @parent = Comment.find_by(id: @comment.comment_id)
      respond_to do |format|
        format.js
      end
    end
  end

  def create
    @comment = current_user.comments.build(comment_params)
    if @comment.save
      @parent = Comment.find_by(id: @comment.comment_id)
      respond_to do |format|
        format.html { redirect_to @comment.post}
        format.js
      end
      if current_user.id != @comment.post.user.id
        ApplicationMailer.comment_added(@comment.post.user, @comment.post).deliver
      end
    else
      redirect_to :back
    end
  end

  def update
    create
  end

  private

  def find_comment
    @comment = Comment.find(params[:id])
  end

  def comment_params
    params.require(:comment).permit(:created_at, :id, :text, :user_id, :post_id, :comment_id)
  end
end
