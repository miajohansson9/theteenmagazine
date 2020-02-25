class PitchesController < ApplicationController
  before_action :find_pitch, only: [:show, :edit, :update, :destroy]
  before_action :is_admin?, only: [:new, :create, :destroy, :edit]
  before_action :authenticate_user!
  load_and_authorize_resource
  layout "minimal"

  #show all pitches
  def index
    @pitches = Pitch.all.order("created_at desc")
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
    if @pitch.update pitch_params
      @pitch.save
      redirect_to pitches_path, notice: "Changes were successfully saved!"
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
  end

  def edit
    @categories = Category.all
  end

  private

  def pitch_params
    params.require(:pitch).permit(:created_at, :title, :description, :slug, :thumbnail, :claimed_id, :category_id, :user_id)
  end

  def find_pitch
    @pitch = Pitch.friendly.find(params[:id])
  end
end
