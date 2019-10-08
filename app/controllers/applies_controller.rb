class AppliesController < ApplicationController
  before_action :is_admin?, only: [:show]

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
    redirect_to root_path unless (current_user && (current_user.admin? || current_user.editor?))
  end

  #show application to editor
  #form for creating a new user already filled out
  def show
    @application = Apply.find(params[:id])
    @user = User.new
  end

  private

  def apply_params
    params.require(:apply).permit(:email, :first_name, :last_name, :nickname, :description, :category)
  end
end
