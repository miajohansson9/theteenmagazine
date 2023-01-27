class OutreachesController < ApplicationController
  before_action :authenticate_user!
  before_action :is_admin?
  before_action :find_outreach, except: %i[index new]

  #show all applications
  def index
    @outreaches_sent = Outreach.where(sent: true).order('created_at desc')
    @outreaches_drafts = Outreach.where(sent: false).order('created_at desc')
  end

  #create a new application
  def new
    @outreach = current_user.outreaches.create
  end

  #send submitted application
  def create
    @outreach = current_user.outreaches.build(outreach_params)
    @outreach.save
  end

  def update
    if @outreach.update outreach_params
      redirect_to @outreach, notice: 'Your changes were saved.'
    else
      render 'new'
    end
  end

  def show
    @user = @outreach.user
  end

  #only allow admin and editors to see submitted applications
  def is_admin?
    if (current_user && (current_user.admin?))
      true
    else
      redirect_to current_user, notice: 'You do not have access to this page.'
    end
  end

  private

  def outreach_params
    params
      .require(:outreach)
      .permit(:partner_email, :partner_name, :sponsored_article_pitch, :sponsored_article_cost, :user_id)
  end

  def find_outreach
    @outreach = Outreach.find(params[:id])
  end
end
