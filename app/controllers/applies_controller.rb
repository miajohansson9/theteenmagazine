class AppliesController < ApplicationController
  before_action :authenticate_user!, except: [:new, :create]
  before_action :is_admin?, only: [:show, :index]

  layout "minimal"

  #show all applications
  def index
    @applies = Apply.all.paginate(page: params[:page]).order("created_at desc")
  end

  #create a new application
  def new
    @application = Apply.new
  end

  #send submitted application
  def create
    @application = Apply.new(apply_params)
    @application.request = request
    if @application.deliver
      flash.now[:error] = nil
    else
      flash.now[:error] = 'Cannot send message'
      render :new
    end
  end

  #only allow admin and editors to see submitted applications
  def is_admin?
    redirect_to new_user_session_path unless (current_user && (current_user.admin? || current_user.editor?))
  end

  #show application to editor
  #form for creating a new user already filled out
  def show
    @application = Apply.find(params[:id])
    # form for new user
    # when submit form, goes to registrations_controller
    @user = User.new
  end

  private

  def apply_params
    params.require(:apply).permit(:email, :first_name, :last_name, :nickname, :description)
  end
end
