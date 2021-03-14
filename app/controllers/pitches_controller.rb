class PitchesController < ApplicationController
  before_action :find_pitch, only: [:show, :update, :edit, :destroy]
  before_action :can_edit?, only: [:edit]
  before_action :is_partner?, only: [:index, :new, :show]
  before_action :authenticate_user!
  load_and_authorize_resource

  #show all pitches
  def index
    if params[:user_id].nil?
      @title = "Editor Pitches"
      @notifications = @notifications - @unseen_pitches_cnt
      @unseen_pitches_cnt = 0
      set_meta_tags :title => @title
      if params[:pitch].nil?
        @pitch = Pitch.new
        @categories = Category.active
        @pagy, @pitches = pagy(Pitch.is_approved.not_claimed.where(status: nil).where("updated_at > ?", Time.now - 40.days).order("updated_at desc"), page: params[:page], items: 20)
      else
        @categories = Category.active
        @category_id = (params[:pitch][:category_id].blank?) ? @categories.map {|category| category.id} : params[:pitch][:category_id]
        @pitch = Pitch.new(category_id: params[:pitch][:category_id])
        @pagy, @pitches = pagy(Pitch.is_approved.not_claimed.where(category_id: @category_id, status: nil).order("updated_at desc"), page: params[:page], items: 20)
      end
      @desc = true
      @message = "There are no unclaimed pitches. Check back in a few days!"
      @button_text = "Claim Pitch"
      Thread.new do
        current_user.update_column('last_saw_pitches', Time.now)
      end
    else
      @title = "Your Claimed Pitches"
      set_meta_tags :title => @title
      @button_text = "View Pitch"
      @message = "You don't have any claimed pitches. :("
      @pagy, @pitches = pagy(Pitch.where(claimed_id: params[:user_id]).order("updated_at desc"), page: params[:page], items: 20)
    end
  end

  #create a new pitch
  def new
    @pitch = current_user.pitches.build
    @categories = Category.active
    set_meta_tags :title => "New Pitch | The Teen Magazine"
  end

  def create
    @categories = Category.active
    @pitch = current_user.pitches.build(pitch_params)
    if @pitch.save && current_user.editor?
      fix_title
      redirect_to "/pitches", notice: "Your pitch was successfully added!"
    elsif @pitch.save
      fix_title
      redirect_to @pitch, notice: "Your pitch was successfully submitted!"
    else
      render 'new', notice: "Oh no! Your changes were not able to be saved!"
    end
  end

  def update
    @categories = Category.active.or(Category.where(id: @pitch.category_id))
    @post = Post.find_by(user_id: @pitch.claimed_id, pitch_id: @pitch.id)
    if @pitch.update pitch_params
      if (@pitch.status.eql? "Ready for Review") && !(pitch_params[:status].eql? "Ready for Review")
        ApplicationMailer.pitch_has_been_reviewed(@pitch.user, @pitch).deliver
      end
      lock_post
      if pitch_params[:claimed_id].eql? ""
        @message = "This pitch was unclaimed. To access your article, reclaim this pitch."
      else
        @message = "Changes were successfully saved."
      end
      fix_title
      redirect_to @pitch, notice: @message
    else
      render 'edit'
    end
  end

  def lock_post
    if @post.present?
      @post.reviews.each do |review|
        review.destroy
      end
      @post.title = "#{@post.title} (locked)"
      @post.save!
      @slug = FriendlyId::Slug.where(slug: @pitch.slug, sluggable_type: "Post")
      @slug&.destroy_all
    end
  end

  def destroy
    if current_user.admin? && !(@pitch.user_id.eql? current_user.id)
      ApplicationMailer.pitch_deleted(@pitch.user, @pitch).deliver
    end
    @pitch.posts.each do |p|
      p.update_column('pitch_id', nil)
    end
    if @pitch&.destroy
      redirect_to pitches_path, notice: "Your pitch was deleted."
    end
  end

  def pitch_modal
    @pitch = Pitch.find(params[:id])
    @post = @pitch.posts.find_by(user_id: @pitch.claimed_id) || current_user.posts.build
    @intent = params[:intent]
    respond_to do |format|
      format.html { redirect_to "/onboarding?step=next_steps"}
      format.js
    end
  end

  def pitch_onboarding_claim
    @pitch = Pitch.find(params[:id])
    @post = current_user.posts.build(post_params)
    @prev_post_pitch = current_user.posts.where(pitch_id: post_params[:pitch_id]).last
    current_user.update(onboarding_claimed_pitch_id: @pitch.id)
    if !(@prev_post_pitch.try(:pitch).nil?)
      @prev_post_pitch.pitch.claimed_id = current_user.id
      @prev_post_pitch.pitch.save
      @prev_post_pitch.reviews.destroy
      @prev_post_pitch.reviews.build(status: "In Progress", active: true)
      @prev_post_pitch.title = Pitch.find(post_params[:pitch_id]).title
      @prev_post_pitch.save
    elsif @post.save && @post.pitch.claimed_id.nil?
      claim_pitch
    end
    respond_to do |format|
      format.html { redirect_to "/onboarding?step=next_steps"}
      format.js
    end
  end

  def claim_pitch
    @post.pitch.update_columns({:claimed_id => current_user.id, :claimed_at => Time.now})
    if @post.pitch.deadline.present?
      @post.update_column('deadline_at', Time.now + (@post.pitch.deadline).weeks)
    end
    @rev = @post.reviews.build(status: "In Progress", active: true)
    @rev.save
    @post.thumbnail = @post.pitch.thumbnail
    @post.save
  end

  def pitch_onboarding_unclaim
    @pitch = Pitch.find(params[:id])
    @post = Post.where(user_id: @pitch.claimed_id, pitch_id: @pitch.id).last
    if @post.present?
      @post.reviews.each do |review|
        review.destroy
      end
      @pitch.posts.where(publish_at: nil, user_id: current_user.id).destroy_all
      current_user.update(onboarding_claimed_pitch_id: nil)
      if @pitch.update(pitch_params)
        @pitches = Pitch.is_approved.not_claimed.where(status: nil).where("updated_at > ?", Time.now - 40.days).order("updated_at desc").paginate(page: params[:page], per_page: 9)
        respond_to do |format|
          format.html { redirect_to "/onboarding?step=next_steps"}
          format.js
        end
      else
        redirect_to "/onboarding?step=next_steps", notice: "Something went wrong"
      end
    end
  end

  #only allow admin and editors to submit new pitches
  def can_edit?
    if (current_user && (current_user.admin? || current_user.editor? || (current_user.id.eql? @pitch.user.id)))
      true
    else
      redirect_to @pitch, notice: "You do not have access to this page."
    end
  end

  def show
    @post = @pitch.posts.find_by(user_id: @pitch.claimed_id) || current_user.posts.build
    @post.title = @pitch.title
    @post.content = "<i>" + @pitch.description + "</i>"
    @claimed_user = @pitch.claimed_id.present? ? User.find_by(id: @pitch.claimed_id) : nil
    @article = @claimed_user ? @claimed_user.posts.where(pitch_id: @pitch.id).last : nil
    if @pitch.status.eql? "Ready for Review"
      @title =  "Pitch Submitted"
      @disabled = "disabled"
      @tooltip = "This pitch has not been reviewed yet"
    elsif @pitch.status.eql? "Rejected"
      @title =  "Pitch Rejected"
      @disabled = "disabled"
      @tooltip = "This pitch was rejected"
    elsif @claimed_user.nil?
      if @pitch.user.editor || (@pitch.user.id.eql? current_user.id)
        @title = "Claim Article Pitch"
        @disabled = ""
        @tooltip = ""
      else
        @title = "#{@pitch.user.full_name} pitched"
        @disabled = "disabled"
        @tooltip = "This pitch isn't yours"
      end
    elsif @claimed_user.id != current_user.id
      @title = "#{@claimed_user.try(:full_name)} claimed the pitch"
      @disabled = "disabled"
      @tooltip = "This pitch isn't yours"
    else
      @title = "You've claimed the pitch"
    end
    @editor = @pitch.editor_id.present? ? User.find(@pitch.editor_id) : nil
    set_meta_tags :title => @pitch.title
  end

  def edit
    @categories = Category.active.or(Category.where(id: @pitch.category_id))
    @pitch_errors = params[:errors]
    @archive_button = @pitch.archive ? "Undo Archive" : "Archive"
    @archive_msg = @pitch.archive ? "" : "Are you sure you want to archive this pitch? It will no longer show up under Editor Pitches."
    set_meta_tags :title => "Edit Pitch | The Teen Magazine"
  end

  def is_partner?
    authenticate_user!
    if !current_user.partner
      true
    else
      redirect_to current_user, notice: "You do not have access to this page."
    end
  end

  private

  def fix_title
    @pitch.title = @pitch.title.split.map{|s| s.slice(0,1).capitalize + s.slice(1..-1)}.join(' ')
    @pitch.title.gsub!(" A ", " a ")
    @pitch.title.gsub!(" Is ", " is ")
    @pitch.title.gsub!(" The ", " the ")
    @pitch.title.gsub!(" For ", " for ")
    @pitch.title.gsub!(" An ", " an ")
    @pitch.title.gsub!(" And ", " and ")
    @pitch.title.gsub!(" Nor ", " nor ")
    @pitch.title.gsub!(" Yet ", " yet ")
    @pitch.title.gsub!(" So ", " so ")
    @pitch.title.gsub!(" At ", " at ")
    @pitch.title.gsub!(" Around ", " around ")
    @pitch.title.gsub!(" But ", " but ")
    @pitch.title.gsub!(" By ", " by ")
    @pitch.title.gsub!(" After ", " after ")
    @pitch.title.gsub!(" Along ", " along ")
    @pitch.title.gsub!(" From ", " from ")
    @pitch.title.gsub!(" Of ", " of ")
    @pitch.title.gsub!(" On ", " on ")
    @pitch.title.gsub!(" To ", " to ")
    @pitch.title.gsub!(" With ", " with ")
    @pitch.title.gsub!(" In ", " in ")
  end

  def pitch_params
    params.require(:pitch).permit(:created_at, :deadline, :title, :description, :slug, :thumbnail, :requirements, :notes, :status, :rejected_title, :rejected_topic, :rejected_thumbnail, :claimed_id, :claimed_at, :category_id, :user_id, :editor_id, :archive)
  end

  def post_params
    params.require(:post).permit(:title, :featured, :newsletter, :editor_can_make_changes, :thumbnail, :ranking, :content, :image, :category_id, :partner_id, :post_impressions, :meta_description, :keywords, :user_id, :admin_id, :pitch_id, :waiting_for_approval, :approved, :sharing, :collaboration, :after_approved, :created_at, :publish_at, :deadline_at, :promoting_until, :slug, :feedback_list => [], :reviews_attributes => [:id, :post_id, :created_at, :status, :notes], :user_attributes => [:extensions, :id])
  end

  def find_pitch
    @pitch = Pitch.find(params[:id])
  end
end
