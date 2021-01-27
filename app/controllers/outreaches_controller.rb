class OutreachesController < ApplicationController
  before_action :authenticate_user!
  before_action :is_admin?

  #show all applications
  def index
    @outreaches_sent = Outreach.where(sent: true).order("created_at desc")
    @outreaches_drafts = Outreach.where(sent: false).order("created_at desc")
  end

  #create a new application
  def new
    @outreach = Outreach.new
  end

  #send submitted application
  def create
    @outreach = Outreach.new(outreach_params)
    @outreach.save
  end

  #only allow admin and editors to see submitted applications
  def is_admin?
    if (current_user && (current_user.admin?))
      true
    else
      redirect_to current_user, notice: "You do not have access to this page."
    end
  end

  #show application to editor
  #form for creating a new user already filled out
  def show
  end

  private

  def outreach_params
    params.require(:outreach).permit(:partner_email, :partner_name, :user_id, :email_draft, :sent)
  end
end
