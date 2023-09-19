include PitchesHelper

class PitchesController < ApplicationController
  before_action :find_pitch, only: %i[show update edit destroy]
  before_action :can_edit?, only: [:edit]
  before_action :is_partner?, only: %i[index new show]
  before_action :is_marketer?, only: [:interviews, :new_interview]
  before_action :authenticate_user!, except: [:pitch_interview, :create]
  load_and_authorize_resource except: [:pitch_interview, :create]

  #show all interview pitches
  def interviews
    set_meta_tags title: "Interview Requests"
    @notifications = @notifications - @unseen_interviews_cnt
    @unseen_interviews_cnt = 0
    all_interviews
    Thread.new { current_user.update_column("last_saw_interviews", Time.now) }
  end

  #show all pitches
  def index
    if params[:user_id].nil?
      @title = "Editor Pitches"
      @notifications = @notifications - @unseen_pitches_cnt
      @unseen_pitches_cnt = 0
      set_meta_tags title: @title
      @categories = Category.active.where.not(slug: "interviews")
      if params[:pitch].nil?
        all_pitches
      else
        filtered_pitches
      end
      @message = "There are no unclaimed pitches. Check back in a few days!"
      @button_text = "Claim Pitch"
      Thread.new { current_user.update_column("last_saw_pitches", Time.now) }
    elsif (params[:user_id].eql? "#{current_user.id}") || current_user.admin
      your_claimed_pitches
    else
      redirect_to pitches_path(user_id: current_user.id), notice: "You can only view your claimed pitches."
    end
  end

  #create a new pitch
  def new
    @pitch = current_user.pitches.build
    @categories = Category.active.where.not(slug: "interviews")
    set_meta_tags title: "New Pitch | The Teen Magazine"
  end

  def pitch_interview
    @pitch = Pitch.new(deadline: 6, category_id: Category.find("interviews").id)
    set_meta_tags title: "Pitch an Interview | The Teen Magazine"
  end

  def new_interview
    @pitch = Pitch.new(deadline: 6, category_id: Category.find("interviews").id, user_id: current_user.id)
    set_meta_tags title: "Create an Interview Pitch | The Teen Magazine"
  end

  def create
    @categories = Category.active
    if params[:button].eql? "interview"
      @pitch = current_user? ? current_user.pitches.build(pitch_params) : Pitch.new(pitch_params)
      if @pitch.save
        if @pitch.user_id.nil?
          ApplicationMailer.confirm_submitted_interview(@pitch.contact_email, @pitch).deliver
          set_meta_tags title: "Interview Submitted"
        else
          redirect_to "/interviews", notice: "The interview request was created successfully."
        end
      else
        render "pitch_interview", notice: "Oh no! Your changes were not able to be saved!"
      end
    else
      @pitch = current_user.pitches.build(pitch_params)
      if !(pitch_params[:agree_to_image_policy].eql? "1")
        redirect_to new_pitch_path, notice: "You have not agreed to the image policy! It cannot be submitted"
        return
      end
      if pitch_params[:thumbnail_url].present?
        image_blob = URI.open(pitch_params[:thumbnail_url])
        @pitch.thumbnail.attach(io: image_blob, filename: "#{@pitch.slug}/thumbnail.jpg")
      end
      if @pitch.save && current_user.editor?
        fix_title
        redirect_to "/pitches", notice: "Your pitch was successfully added!"
      elsif @pitch.save
        fix_title
        redirect_to @pitch, notice: "Your pitch was successfully submitted!"
      else
        render "new", notice: "Oh no! Your changes were not able to be saved!"
      end
    end
  end

  def update
    @categories = Category.active.or(Category.where(id: @pitch.category_id))
    @post = Post.find_by(user_id: @pitch.claimed_id, pitch_id: @pitch.id)
    if pitch_params[:thumbnail_url].present?
      image_blob = URI.open(pitch_params[:thumbnail_url])
      @pitch.thumbnail.attach(io: image_blob, filename: "#{@pitch.slug}/thumbnail.jpg", content_type: 'image/jpeg')
    end
    if @pitch.update pitch_params
      if (@pitch.status.eql? "Ready for Review") &&
         !(pitch_params[:status].eql? "Ready for Review")
        ApplicationMailer.pitch_has_been_reviewed(@pitch.user, @pitch).deliver
      end
      if pitch_params[:claimed_id].eql? ""
        lock_post
        @message =
          "This pitch was unclaimed. To access your article, reclaim this pitch."
      else
        @message = "Changes were successfully saved."
      end
      fix_title
      redirect_to @pitch, notice: @message
    else
      render "edit"
    end
  end

  def lock_post
    if @post.present? && !(@post.title.include? " (locked)")
      @post.reviews.each { |review| review.destroy }
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
    @pitch.posts.each { |p| p.update_column("pitch_id", nil) }
    if @pitch.is_interview? && @pitch&.destroy
      redirect_to interviews_path, notice: "Your pitch was deleted."
    elsif @pitch&.destroy
      redirect_to pitches_path, notice: "Your pitch was deleted."
    end
  end

  def pitch_modal
    @pitch = Pitch.find(params[:id])
    @post =
      @pitch.posts.find_by(user_id: @pitch.claimed_id) ||
        current_user.posts.build
    @intent = params[:intent]
    respond_to do |format|
      format.html { redirect_to "/onboarding?step=next_steps" }
      format.js
    end
  end

  def pitch_onboarding_claim
    @pitch = Pitch.find(params[:id])
    @post = current_user.posts.build(post_params)
    @prev_post_pitch =
      current_user.posts.where(pitch_id: post_params[:pitch_id]).last
    current_user.update(onboarding_claimed_pitch_id: @pitch.id)
    # if user has already claimed this pitch
    if !(@prev_post_pitch.try(:pitch).nil?)
      @prev_post_pitch.pitch.claimed_id = current_user.id
      @prev_post_pitch.pitch.save
      @prev_post_pitch.reviews.destroy
      @prev_post_pitch.reviews.build(status: "In Progress", active: true)
      @prev_post_pitch.title = Pitch.find(post_params[:pitch_id]).title
      @prev_post_pitch.thumbnail.attach(@pitch.thumbnail.blob)
      @prev_post_pitch.save
    elsif @post.save && @post.pitch.claimed_id.nil?
      claim_pitch
    end
    respond_to do |format|
      format.html { redirect_to "/onboarding?step=next_steps" }
      format.js
    end
  end

  def claim_pitch
    @post.pitch.update_columns(
      { claimed_id: current_user.id, claimed_at: Time.now }
    )
    if @post.pitch.deadline.present?
      @post.update_column(
        "deadline_at",
        Time.now + (@post.pitch.deadline).weeks
      )
    end
    @rev = @post.reviews.build(status: "In Progress", active: true)
    @rev.save
    @post.thumbnail.attach(@post.pitch.thumbnail.blob)
    @post.save
  end

  def pitch_onboarding_unclaim
    @pitch = Pitch.find(params[:id])
    @post = Post.where(user_id: @pitch.claimed_id, pitch_id: @pitch.id).last
    if @post.present?
      @post.reviews.each { |review| review.destroy }
      @pitch.posts.where(publish_at: nil, user_id: current_user.id).destroy_all
      current_user.update(onboarding_claimed_pitch_id: nil)
      if @pitch.update(pitch_params)
        @pitches =
          Pitch
            .is_approved
            .not_claimed
            .where(status: nil)
            .where("updated_at > ?", Time.now - 90.days)
            .order("updated_at desc")
            .paginate(page: params[:page], per_page: 9)
        respond_to do |format|
          format.html { redirect_to "/onboarding?step=next_steps" }
          format.js
        end
      else
        redirect_to "/onboarding?step=next_steps",
                    notice: "Something went wrong"
      end
    end
  end

  #only allow admin and editors to submit new pitches
  def can_edit?
    if (current_user &&
        (current_user.admin? || current_user.editor? ||
         (current_user.id.eql? @pitch.user.id)))
      true
    else
      redirect_to @pitch, notice: "You do not have access to this page."
    end
  end

  def show
    @post =
      @pitch.posts.find_by(user_id: @pitch.claimed_id) ||
        current_user.posts.build
    @post.title = @pitch.title
    @post.content = "<i>" + @pitch.description + "</i>"
    @claimed_user =
      @pitch.claimed_id.present? ? User.find_by(id: @pitch.claimed_id) : nil
    @article =
      @claimed_user ? @claimed_user.posts.where(pitch_id: @pitch.id).last : nil
    if @pitch.thumbnail_credits.present?
      @thumbanil_credits =
        (@pitch.thumbnail_credits.include? ",") ? @pitch.thumbnail_credits.split(",") : [@pitch.thumbnail_credits.upcase]
    end
    if @pitch.status.eql? "Ready for Review"
      @title = "Pitch Submitted"
      @disabled = "disabled"
      @tooltip = "This pitch has not been reviewed yet"
    elsif @pitch.status.eql? "Rejected"
      @title = "Pitch Rejected"
      @disabled = "disabled"
      @tooltip = "This pitch was rejected"
    elsif @claimed_user.nil?
      if @pitch.user.nil? || @pitch.user.editor || (@pitch.user.id.eql? current_user.id)
        @title = @pitch.is_interview? ? "Claim Interview" : "Claim Article Pitch"
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
    set_meta_tags title: @pitch.title
  end

  def edit
    @categories = Category.active.or(Category.where(id: @pitch.category_id))
    @pitch_errors = params[:errors]
    @archive_button = @pitch.archive ? "Undo Archive" : "Archive"
    @archive_msg = if @pitch.archive
        ""
      else
        "Are you sure you want to archive this pitch? It will no longer show up under Editor Pitches."
      end
    set_meta_tags title: "Edit Pitch | The Teen Magazine"
  end

  def is_partner?
    authenticate_user!
    if !current_user.partner
      true
    else
      redirect_to current_user, notice: "You do not have access to this page."
    end
  end

  def is_marketer?
    unless current_user && current_user.is_marketer?
      redirect_to "/login", notice: "You do not have access to this page."
    end
  end

  private

  def fix_title
    @pitch.title =
      @pitch
        .title
        .split
        .map { |s| s.slice(0, 1).capitalize + s.slice(1..-1) }
        .join(" ")
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
    params
      .require(:pitch)
      .permit(
        :created_at,
        :deadline,
        :title,
        :description,
        :slug,
        :thumbnail,
        :thumbnail_url,
        :requirements,
        :notes,
        :status,
        :rejected_title,
        :rejected_topic,
        :rejected_thumbnail,
        :claimed_id,
        :claimed_at,
        :category_id,
        :user_id,
        :editor_id,
        :archive,
        :contact_email,
        :influencer_social_media,
        :platform_to_share,
        :interview_kind,
        :following_level,
        :thumbnail_credits,
        :agree_to_image_policy,
        :agree_to_image_policy_at,
        :admin_notes,
        :priority
      )
  end

  def post_params
    params
      .require(:post)
      .permit(
        :title,
        :featured,
        :newsletter,
        :editor_can_make_changes,
        :thumbnail,
        :ranking,
        :content,
        :image,
        :category_id,
        :partner_id,
        :post_impressions,
        :meta_description,
        :keywords,
        :user_id,
        :admin_id,
        :pitch_id,
        :waiting_for_approval,
        :approved,
        :sharing,
        :collaboration,
        :after_approved,
        :created_at,
        :publish_at,
        :deadline_at,
        :shared_at,
        :promoting_until,
        :agree_to_image_policy,
        :thumbnail_credits,
        :slug,
        feedback_list: [],
        reviews_attributes: %i[id post_id created_at status notes editor_id],
        user_attributes: %i[extensions id],
      )
  end

  def find_pitch
    @pitch = Pitch.find(params[:id])
  end
end
