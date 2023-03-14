class CommentsController < ApplicationController
  before_action :find_comment, only: %i[destroy update edit]

  def destroy
    @post = @comment.post
    if @comment.destroy
      @parent = Comment.find_by(id: @comment.comment_id)
      respond_to { |format| format.js }
    end
  end

  def create
    if current_user.present?
      @comment = current_user.comments.build(comment_params)
    else
      @comment = Comment.new(comment_params)
      session[:cookie] = comment_params[:cookie]
      session[:full_name] = comment_params[:full_name]
      session[:email] = comment_params[:email]
      session[:subscribed] = comment_params[:subscribed]
    end
    if @comment.save
      @parent = Comment.find_by(id: @comment.comment_id)
      respond_to do |format|
        format.html { redirect_to @comment.post }
        format.js
      end
      if current_user.present? && current_user.id != @comment.post.user.id
        if @comment.post.promoting_until.present? &&
             @comment.post.promoting_until > Time.now
          @points = @comment.text.size / 10
          @points = @points < 20 ? 20 : @points
        else
          @points = @comment.text.size / 20
          @points = @points < 10 ? 10 : @points
        end
        current_user.points = current_user.points + @points
        current_user.save
      end
      # don't send email if commented on own article
      if !(current_user && current_user.id == @comment.post.user.id)
        Thread.new do
          ApplicationMailer.comment_added(@comment.post.user, @comment.post).deliver
        end
      end
    else
      redirect_to :back
    end
  end

  def update
    respond_to do |format|
      if @comment.update(comment_params)
        format.js {}
        format.html { redirect_to @comment.post }
      else
        format.js {}
        format.html { render :edit }
      end
    end
  end

  def edit
    @cookie = params[:cookie]
  end

  def new
    @parent = Comment.find(params[:parent_id])
    @replies = @parent.comments
    @post = @parent.post
    if current_user.present?
      @comment = current_user.comments.build
    else
      @comment = Comment.new(cookie: params[:cookie])
    end
  end

  private

  def find_comment
    @comment = Comment.find(params[:id])
  end

  def comment_params
    params
      .require(:comment)
      .permit(
        :created_at,
        :id,
        :text,
        :user_id,
        :post_id,
        :comment_id,
        :response_to,
        :email,
        :subscribed,
        :full_name,
        :cookie,
        :public
      )
  end
end
