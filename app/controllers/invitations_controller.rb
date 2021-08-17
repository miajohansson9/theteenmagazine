class InvitationsController < ApplicationController
  before_action :authenticate_user!, except: [:show, :apply_through_invitation]
  skip_before_action :verify_authenticity_token, only: [:apply_through_invitation]

  def index
    if !(params[:id].eql? current_user.slug) && !current_user.admin
      redirect_to "/writers/#{current_user.slug}/invitations", notice: "You do not have access to that page."
    end
    begin
      @user = User.find(params[:id])
    rescue
      redirect_to "/writers/#{current_user.slug}/invitations"
    end
    @invitation = Invitation.new
    set_meta_tags :title => "Invitations"
  end

  def create
    @invitation = current_user.invitations.build(invitation_params)
    @active_invite_already_exists = current_user.invitations.where("lower(email) = ? AND status != 'Expired'", invitation_params[:email].downcase).present?
    @active_user_already_exists = User.find_by(email: invitation_params[:email]).present?
    if !(@active_invite_already_exists || @active_user_already_exists)
      if @invitation.save
        ApplicationMailer.invitation_to_apply(invitation_params[:email], current_user, @invitation).deliver
        @invites_left_to_earn_points = 5 - current_user.invitations.count % 5
        if @invites_left_to_earn_points.eql? 5
          current_user.update_column('points', current_user.points + 250)
        end
      else
        redirect_to "/writers/#{current_user.slug}/invitations", notice: "Oh no, something went wrong!"
      end
    end
    respond_to do |format|
      format.html {}
      format.js
    end
  end

  def send_another_invite
    respond_to do |format|
      format.html {}
      format.js
    end
  end

  def get_sent_invitations
    @user = User.find(params[:user])
    @invitations = @user.invitations.order('created_at desc')
    render partial: "invitations/partials/invites/past_invites"
  end

  def get_sent_invitations_admin
    @invitations = Invitation.all.order('created_at desc')
    render partial: "invitations/partials/invites/past_invites"
  end

  def show
    @invitation = Invitation.find_by(token: params[:token])
    @user = @invitation.user
    @application = @invitation.applies.last || Apply.new
    @disabled = @application.created_at.present? ? "disabled" : ""
    if current_user.nil?
      if ["Not viewed", "Viewed"].include? @invitation.status
        @invitation.update_column("status", "Viewed")
      end
      @invitation.update_column("impressions", @invitation.impressions + 1)
    end
    set_meta_tags :title => "Invite from #{@invitation.user.first_name} | The Teen Magazine"
  end

  def dismissed_notification
    @invitation = Invitation.find(params[:id])
    if @invitation.user_id.eql? current_user.id
      @invitation.update_column("alert_viewed_at", Time.now)
    end
  end

  def apply_through_invitation
    @invitation = Invitation.find_by(token: params[:token])
    @user = @invitation.user
    @application = @invitation.applies.build(apply_params)
    @application.request = request
    if @application.deliver
      flash.now[:error] = nil
      begin
        @invitation.update_column("status", "Applied")
        @user.update_column("promotions", @user.promotions + 1)
      rescue e
        puts e
      end
    else
      flash.now[:error] = "An error occured. Please check that you've filled out all the fields."
      render :show
    end
  end

  private

  def invitation_params
    params.require(:invitation).permit(:id, :status, :user_id, :email, :apply_id, :impressions, :token, :alert_viewed_at)
  end

  def apply_params
    params.require(:apply).permit(:email, :first_name, :last_name, :nickname, :description, :sample_writing, :resume, :grade, :user_id, :editor_revision, :editor_feedback, :editor_pitches, :kind, :rejected_writer_at, :rejected_editor_at, :invitation_id)
  end
end
