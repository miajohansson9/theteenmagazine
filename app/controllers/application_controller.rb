class ApplicationController < ActionController::Base
  include CanCan::ControllerAdditions
  include Pagy::Backend

  protect_from_forgery with: :exception

  before_action :configure_permitted_parameters, if: :devise_controller?
  before_action :notifications, if: :current_user?

  after_action :store_user_location!, if: :storable_location?, only: :authenticate_user
  # The callback which stores the current location must be added before you authenticate the user
  # as `authenticate_user!` (or whatever your resource is) will halt the filter chain and redirect
  # before the location can be stored.

  layout :set_layout

  protected

  def set_layout
    if current_user
      'writer'
    else
      'application'
    end
  end

  # Its important that the location is NOT stored if:
  # - The request method is not GET (non idempotent)
  # - The request is handled by a Devise controller such as Devise::SessionsController as that could cause an
  #    infinite redirect loop.
  # - The request is an Ajax request as this can lead to very unexpected behaviour.

  def notifications
    initiate_last_seen
    @unseen_pitches = Pitch.is_approved.not_claimed.where(status: nil).where.not(user_id: current_user.id).where('updated_at > ?', current_user.last_saw_pitches)
    @unseen_pitches_cnt = @unseen_pitches.size

    @unseen_shared_drafts  = Post.where(sharing: true, publish_at: nil).draft.where('posts.updated_at > ?', current_user.last_saw_community)
    @unseen_shared_drafts_cnt  = @unseen_shared_drafts.size

    @notifications = @unseen_pitches_cnt + @unseen_shared_drafts_cnt
    if current_user.editor?
      @unseen_posts = Review.where(:status => "Ready for Review", active: true).where('updated_at > ?', current_user.last_saw_editor_dashboard).map{|r| Post.find_by(id: r.post_id)}.reject(&:blank?)
      @unseen_submitted_pitches = Pitch.is_submitted.where('updated_at > ?', current_user.last_saw_editor_dashboard)
      @unseen_editor_dashboard_cnt = @unseen_submitted_pitches.size + @unseen_posts.size
      @notifications = @notifications + @unseen_editor_dashboard_cnt
    end
    if current_user.admin?
      @unseen_applications = Apply.where('created_at > ?', current_user.last_saw_writer_applications).or(Apply.where(kind: "Editor", rejected_editor_at: nil).where('updated_at > ?', current_user.last_saw_writer_applications))
      @unseen_applications_cnt = @unseen_applications.size
      @notifications = @notifications + @unseen_applications_cnt
    end
  end

  def current_user?
    current_user.present?
  end

  def storable_location?
    if current_user.nil?
      request.get? && is_navigational_format? && !devise_controller? && !request.xhr?
    end
  end

  def store_user_location!
    # :user is the scope we are authenticating
    store_location_for(:user, request.fullpath)
  end

  def configure_permitted_parameters
    devise_parameter_sanitizer.permit(:sign_up) { |u| u.permit(:email, :admin, :first_name, :last_name, :image, :password, :description, :editor) }
  end

  def after_sign_in_path_for(resource)
    stored_location_for(resource) || resource
  end

  def initiate_last_seen
    if current_user.last_saw_pitches.nil? && !(current_user.partner)
      current_user.update_column('last_saw_pitches', Time.now)
      current_user.update_column('last_saw_pitches', Time.now)
    end
    if current_user.admin && current_user.last_saw_writer_applications.nil?
      current_user.update_column('last_saw_writer_applications', Time.now)
    end
    if current_user.editor && current_user.last_saw_editor_dashboard.nil?
      current_user.update_column('last_saw_editor_dashboard', Time.now)
    end
  end
end
