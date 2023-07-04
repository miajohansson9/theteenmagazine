class CommentsController < ApplicationController
  before_action :find_comment, only: %i[destroy update edit]
  invisible_captcha only: [:create, :update], honeypot: :subtitle
  
  def destroy
    @post = @comment.post
    if @comment.destroy
      @parent = Comment.find_by(id: @comment.comment_id)
      respond_to { |format| format.js }
    end
  end

  def get_all_comments
    @comments = Comment.all.order(:created_at => :desc).limit(20)
    render partial: "comments/all_comments"
  end

  def language_is_not_english
    @languages = Linguo.detect(comment_params[:text], ENV['LANG_API_KEY']).detections
    for lang in @languages
      if !(lang['language'].eql? 'en') && (lang['isReliable'].eql? true)
        # not english
        return true
      end
    end
    # is english
    return false
  end

  def filled_out_honeypot
    value = params['subtitle']
    if value.present?
      Sentry.capture_message("Filled out honeypot captcha: #{value}")
      return true
    end
    return false
  end

  def create
    puts "SDLJKFLSKDJF"
    if Obscenity.profane?(comment_params[:full_name]) ||
       Obscenity.profane?(comment_params[:email]) ||
       Obscenity.profane?(comment_params[:text]) ||
       filled_out_honeypot ||
       (comment_params[:full_name].present? && 
        comment_params[:full_name].length > 50) ||
       (comment_params[:text].include? "http") ||
       (comment_params[:text].include? "href") ||
       (comment_params[:text].include? "/>") ||
       (comment_params[:full_name]&.include? "/") ||
       (comment_params[:full_name]&.include? "http") ||
       (comment_params[:full_name]&.include? "href") ||
       language_is_not_english
      # profane comment submitted
      if comment_params[:response_to].present?
        redirect_to '/no_profanity.html'
      else
        respond_to do |format|
          format.js { render js: "window.location='#{request.base_url + "/no_profanity.html"}'" }
        end
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
        if (comment_params[:subscribed].eql? "1")
          # subscribe to TTM newsletter
          maybe_subscriber = Subscriber.find_by('lower(email) = ?', comment_params[:email].downcase)
          if !maybe_subscriber.present?
            @first_name = comment_params[:full_name]
            @last_name = ''
            @token = SecureRandom.urlsafe_base64
            if @first_name.present? && @first_name.include?(' ')
                @first_name = @first_name.split(' ')[0]
                @last_name = @first_name.split(' ')[1]
            end
            if comment_params[:email].present?
              subscriber = Subscriber.new(
                  email: comment_params[:email], 
                  first_name: @first_name, 
                  last_name: @last_name, 
                  token: @token,
                  source: "Comment on #{@comment.post.title}",
                  opted_in_at: Time.now,
                  subscribed_to_reader_newsletter: true,
                  subscribed_to_writer_newsletter: false,
              )
              subscriber.save
            end
          else
            maybe_subscriber.update_column("subscribed_to_reader_newsletter", true)
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
