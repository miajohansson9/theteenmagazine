class CommentsController < ApplicationController
  before_action :find_comment, only: %i[destroy update edit]

  def destroy
    @post = @comment.post
    if @comment.destroy
      @parent = Comment.find_by(id: @comment.comment_id)
      respond_to { |format| format.js }
    end
  end

  def get_all_comments
    @comments = Comment.all.order(:created_at => :desc)
    render partial: "comments/all_comments"
  end

  def create
    if Obscenity.profane?(comment_params[:full_name]) ||
       Obscenity.profane?(comment_params[:email]) ||
       Obscenity.profane?(comment_params[:text])
      # profane comment submitted
      respond_to do |format|
        format.js { render js: "window.location='#{request.base_url + "/no_profanity.html"}'" }
      end
    else
      if current_user.present?
        @comment = current_user.comments.build(comment_params)
      else
        @comment = Comment.new(comment_params)
        cookies[:cookie] = comment_params[:cookie]
        cookies[:full_name] = comment_params[:full_name]
        cookies[:email] = comment_params[:email]
        cookies[:is_thirteen] = comment_params[:is_thirteen]
        if comment_params[:subscribed].eql? "1"
          # subscribe to TTM newsletter
          Thread.new do
            @gb = Gibbon::Request.new(api_key: ENV["MAILCHIMP_API_KEY"])
            begin
              @gb
                .lists(ENV["MAILCHIMP_LIST_ID"])
                .members(comment_params[:email])
                .update(body: { status: "subscribed" })
            rescue StandardError
              @gb
                .lists(ENV["MAILCHIMP_LIST_ID"])
                .members
                .create(
                  body: {
                    email_address: comment_params[:email],
                    status: "subscribed",
                    merge_fields: { FNAME: comment_params[:full_name], SLOCATION: "Comment on #{@comment.post.title}" },
                  },
                )
            end
          end
        end
        cookies[:subscribed] = comment_params[:subscribed]
      end
      if @comment.save
        @parent = Comment.find_by(id: @comment.comment_id)
        respond_to do |format|
          format.html { redirect_to @comment.post }
          format.js
        end
        if current_user.present?
          if @comment.post.promoting_until.present? &&
             @comment.post.promoting_until > Time.now
            @points = @comment.text.size / 5
            @points = @points < 20 ? 20 : @points
          else
            @points = @comment.text.size / 10
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
  end

  def update
    respond_to do |format|
      if @comment.update(comment_params)
        format.js { }
        format.html { redirect_to @comment.post }
      else
        format.js { }
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
        :public,
        :is_thirteen,
      )
  end
end
