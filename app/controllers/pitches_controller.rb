class PitchesController < ApplicationController
  before_action :find_pitch, only: [:show, :edit, :update, :destroy]
  before_action :is_admin?, only: [:new, :create, :destroy, :edit]
  before_action :authenticate_user!
  load_and_authorize_resource
  layout "minimal"

  #show all pitches
  def index
    if params[:user_id].nil?
      if params[:pitch].nil?
        @pitch = Pitch.new
        @categories = Category.all
        @pitches = Pitch.all.where(claimed_id: nil).paginate(page: params[:page]).order("updated_at desc")
      else
        @categories = Category.all
        @category_id = (params[:pitch][:category_id].blank?) ? @categories.map {|category| category.id} : params[:pitch][:category_id]
        @pitch = Pitch.new(category_id: params[:pitch][:category_id])
        @pitches = Pitch.all.where(category_id: @category_id, claimed_id: nil).paginate(page: params[:page]).order("updated_at desc")
      end
      @title = "Editor Pitches"
      @desc = true
      @message = "There are no unclaimed pitches. Check back in a few days!"
      @button_text = "Claim Article Pitch"
    else
      @title = "Your claimed pitches"
      @button_text = "View Pitch"
      @message = "You don't have any claimed pitches. :("
      @pitches = Pitch.all.where(claimed_id: params[:user_id]).paginate(page: params[:page]).order("updated_at desc")
    end
  end

  #create a new pitch
  def new
    @pitch = current_user.pitches.build
    @categories = Category.all
  end

  def create
    @categories = Category.all
    @pitch = current_user.pitches.build(pitch_params)
    if @pitch.save
      redirect_to "/pitches", notice: "Your pitch was successfully added!"
    else
      render 'new', notice: "Oh no! Your changes were not able to be saved!"
    end
  end

  def update
    @categories = Category.all
    if (@pitch.claimed_id == current_user.id || current_user.admin?) && pitch_params[:claimed_id].blank?
      @post = Post.where(user_id: @pitch.claimed_id, pitch_id: @pitch.id).last
      @post.reviews.each do |review|
        review.destroy
      end
      @slug = FriendlyId::Slug.where(slug: @post.slug).first
      @slug.destroy
      @post.title = "#{@post.title} (locked)"
      @post.save
      @message = "You've unclaimed this pitch."
    else
      @message = "Changes were successfully saved!"
    end
    if @pitch.update pitch_params
      @pitch.save
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
  def is_admin?
    redirect_to root_path unless (current_user && (current_user.admin? || current_user.editor?))
  end

  def show
    @post = current_user.posts.build
    @post.title = @pitch.title
    @post.content = "<i>" + @pitch.description + "</i>"
    @claimed_user = @pitch.claimed_id.present? ? User.find(@pitch.claimed_id) : nil
    @article = @claimed_user ? @claimed_user.posts.where(pitch_id: @pitch.id).last : nil
    @title = @claimed_user.nil? ? "Claim article pitch" : "You've claimed this pitch"
  end

  def edit
    @categories = Category.all
  end

  private

  def pitch_params
    params.require(:pitch).permit(:created_at, :title, :description, :slug, :thumbnail, :requirements, :claimed_id, :category_id, :user_id)
  end

  def find_pitch
    @pitch = Pitch.friendly.find(params[:id])
  end
end