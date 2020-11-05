class PitchesController < ApplicationController
  before_action :find_pitch, only: [:show, :edit, :update, :destroy]
  before_action :can_edit?, only: [:edit]
  before_action :is_partner?, only: [:index, :new, :show]
  before_action :authenticate_user!
  load_and_authorize_resource
  layout "minimal"

  #show all pitches
  def index
    if params[:user_id].nil?
      @title = "Editor Pitches"
      @notifications = @notifications - @unseen_pitches_cnt
      @unseen_pitches_cnt = 0
      set_meta_tags :title => @title
      if params[:pitch].nil?
        @pitch = Pitch.new
        @categories = Category.all
        @pitches = Pitch.is_approved.not_claimed.where(status: nil).paginate(page: params[:page]).order("updated_at desc")
      else
        @categories = Category.all
        @category_id = (params[:pitch][:category_id].blank?) ? @categories.map {|category| category.id} : params[:pitch][:category_id]
        @pitch = Pitch.new(category_id: params[:pitch][:category_id])
        @pitches = Pitch.is_approved.not_claimed.where(category_id: @category_id, status: nil).paginate(page: params[:page]).order("updated_at desc")
      end
      @desc = true
      @message = "There are no unclaimed pitches. Check back in a few days!"
      @button_text = "Claim Pitch"
      current_user.last_saw_pitches = Time.now
      current_user.save
    else
      @title = "Your Claimed Pitches"
      set_meta_tags :title => @title
      @button_text = "View Pitch"
      @message = "You don't have any claimed pitches. :("
      @pitches = Pitch.all.where(claimed_id: params[:user_id]).paginate(page: params[:page]).order("updated_at desc")
    end
  end

  #create a new pitch
  def new
    @pitch = current_user.pitches.build
    @categories = Category.all
    set_meta_tags :title => "New Pitch | The Teen Magazine"
  end

  def create
    @categories = Category.all
    @pitch = current_user.pitches.build(pitch_params)
    fix_title
    if @pitch.save && current_user.editor?
      redirect_to "/pitches", notice: "Your pitch was successfully added!"
    elsif @pitch.save
      redirect_to @pitch, notice: "Your pitch was successfully submitted!"
    else
      render 'new', notice: "Oh no! Your changes were not able to be saved!"
    end
  end

  def update
    @categories = Category.all
    if (@pitch.status.eql? "Ready for Review") && !(pitch_params[:status].eql? "Ready for Review")
      ApplicationMailer.pitch_has_been_reviewed(@pitch.user, @pitch).deliver
    end
    if (@pitch.claimed_id == current_user.id || current_user.admin?) && pitch_params[:claimed_id].blank?
      @post = Post.where(user_id: @pitch.claimed_id, pitch_id: @pitch.id).last
      if @post.present?
        @post.reviews.each do |review|
          review.destroy
        end
        @slug = FriendlyId::Slug.where(slug: @post.slug).first
        @slug.destroy
        @post.title = "#{@post.title} (locked)"
        @post.save
      end
      if current_user.admin?
        @message = "Changes were successfully saved!"
      else
        @message = "You've unclaimed this pitch."
      end
    else
      @message = "Changes were successfully saved!"
    end
    if @pitch.update pitch_params
      fix_title
      redirect_to @pitch, notice: @message
    else
      render 'edit', notice: "Oops, something went wrong."
    end
  end

  def destroy
    if @pitch.destroy
      redirect_to pitches_path, notice: "Your pitch was deleted."
    end
  end

  def claim
    @pitch.user_id = current_user.id
    @pitch.save
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
    @post = current_user.posts.build
    @post.title = @pitch.title
    @post.content = "<i>" + @pitch.description + "</i>"
    @claimed_user = @pitch.claimed_id.present? ? User.find(@pitch.claimed_id) : nil
    @article = @claimed_user ? @claimed_user.posts.where(pitch_id: @pitch.id).last : nil
    if @pitch.status.eql? "Ready for Review"
      @title =  "Pitch Submitted"
      @class = "disabled"
      @tooltip = "This pitch has not been reviewed yet"
    elsif @pitch.status.eql? "Rejected"
      @title =  "Pitch Rejected"
      @class = "disabled"
      @tooltip = "This pitch was rejected"
    elsif @claimed_user.nil?
      if @pitch.user.editor || (@pitch.user.id.eql? current_user.id)
        @title = "Claim Article Pitch"
        @class = ""
        @tooltip = ""
      else
        @title = "#{@pitch.user.full_name} pitched"
        @class = "disabled"
        @tooltip = "This pitch isn't yours"
      end
    else
      @title = "You've claimed the pitch"
    end
    @editor = @pitch.editor_id.present? ? User.find(@pitch.editor_id) : nil
    set_meta_tags :title => @pitch.title
  end

  def edit
    @categories = Category.all
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
    params.require(:pitch).permit(:created_at, :title, :description, :slug, :thumbnail, :requirements, :notes, :status, :rejected_title, :rejected_topic, :rejected_thumbnail, :claimed_id, :category_id, :user_id, :editor_id)
  end

  def find_pitch
    @pitch = Pitch.friendly.find(params[:id])
  end
end
